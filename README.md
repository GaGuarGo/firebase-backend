# Firebase Backend

> Solução modular para abstração de endpoints, DTOs, entidades e integração com Firebase Auth/Firestore em Dart/Flutter.

## ✨ Features

- Abstração de endpoints Firestore (GET, POST, UPDATE, DELETE, STREAM)
- Transactions com validação e verificação da regra leia-antes-de-escrever
- DTOs e entidades desacopladas, com validação que reporta todos os campos
- Hierarquia única de exceções (`FirebaseBackendException`)
- Handlers para códigos de erro do Firebase Auth, com mensagens sobrescrevíveis
- Testável sem projeto Firebase: todas as dependências são injetáveis

## 🚀 Getting Started

1. **Adicione o pacote ao seu projeto:**

	 No `pubspec.yaml` do projeto que for integrar:
	 ```yaml
	 dependencies:
		 firebase_backend:
			 git:
				 url: https://github.com/triplegtech/firebase-backend.git
				 ref: main # ou a branch/tag desejada
	 ```

2. **Inicialize o Firebase:**

	 ```dart
	 await initFirebaseBackend(options: DefaultFirebaseOptions.currentPlatform);
	 ```

	 Para App Check, passe `appCheck: true`. Na web é obrigatório informar
	 `recaptchaSiteKey`; em Android e Apple os providers padrão são Play Integrity
	 e Device Check, ajustáveis via `providerAndroid` / `providerApple`.

3. **Implemente seus DTOs, entidades e endpoints:**
	- Crie DTOs herdando de `FirebaseRequestDto` e `FirebaseResponseDto`;
	- Crie entidades de domínio para separar regras de negócio;
	- Implemente endpoints herdando de `FirebaseGetEndpoint`, `FirebasePostEndpoint`, `FirebaseStreamEndpoint`;
	- Para upload de arquivos, utilize `FirebaseUploadToStorage`.

## 🛠️ Usage Example

```dart
import 'package:firebase_backend/firebase_backend.dart';

class UserDto extends FirebaseRequestDto {
	UserDto({required this.email, required this.name});

	final String email;
	final String name;

	@override
	Map<String, dynamic> toJson() => {'email': email, 'name': name};

	// Não pare no primeiro erro: acumule todos e o chamador mostra de uma vez.
	@override
	void onValidate() {
		if (!isValidEmail(email)) addError('email', 'Email inválido');
		if (name.isEmpty) addError('name', 'Nome não pode ser vazio');
	}
}

class UserResponseDto extends FirebaseResponseDto<UserEntity> {
	// ...
}

class UserGetEndpoint extends FirebaseGetEndpoint<UserResponseDto> {
	@override
	String get path => 'users';

	@override
	UserResponseDto buildResponse(DocumentSnapshot<Map<String, dynamic>> doc) {
		// ...
	}
}

class UserPostEndpoint extends FirebasePostEndpoint<UserDto, UserResponseDto> {
	@override
	String get path => 'users';

	@override
	UserResponseDto buildResponse(
		DocumentReference<Map<String, dynamic>> docRef,
		UserDto dto,
	) {
		// ...
	}
}

// Uso:
final user = await UserGetEndpoint().findOne('userId');

final ativos = await UserGetEndpoint().findAll(
	queryBuilder: (query) => query.where('active', isEqualTo: true).limit(20),
);

// ID automático:
await UserPostEndpoint().post(UserDto(email: 'a@b.com', name: 'Ana'));

// ID escolhido (útil para `users/{uid}`):
await UserPostEndpoint().post(dto, documentId: uid);
```

## 🔁 Transactions

Use quando várias leituras e escritas precisam acontecer atomicamente. O
`FirebaseTransactionContext` valida os DTOs e verifica a regra do Firestore de
que **toda leitura vem antes da primeira escrita** — violá-la produz uma
exceção nomeada em vez do erro opaco da plataforma.

```dart
class TransferFunds extends FirebaseTransactionEndpoint<TransferDto, void> {
	@override
	String get path => 'accounts';

	@override
	Future<void> execute(FirebaseTransactionContext ctx, TransferDto dto) async {
		// Todas as leituras primeiro.
		final from = await ctx.get(doc(dto.fromId));
		final to = await ctx.get(doc(dto.toId));

		final balance = from.data()!['balance'] as int;
		if (balance < dto.amount) throw InsufficientFunds();

		// Depois as escritas.
		ctx.updateRaw(from.reference, {'balance': balance - dto.amount});
		ctx.updateRaw(to.reference, {'balance': FieldValue.increment(dto.amount)});
	}
}

await TransferFunds().run(dto);
```

> ⚠️ O corpo de `execute` **pode rodar várias vezes**: o Firestore reexecuta a
> transaction quando um documento lido é alterado concorrentemente. Mantenha-o
> livre de efeitos colaterais (logs que devem ocorrer uma vez, notificações,
> mutação de estado externo) e faça isso depois que `run` retornar.

Endpoints já existentes também aceitam uma transaction, o que evita reescrever
a lógica de leitura e escrita:

```dart
await FirebaseBackend.firestore.runTransaction((transaction) async {
	final user = await UserGetEndpoint().findOne(uid, transaction: transaction);
	await UserUpdateEndpoint().update(uid, dto, transaction: transaction);
});
```

`findAll` não aceita transaction: o Firestore só permite ler documentos
individuais dentro de uma.

## 🔄 Stream Endpoint

```dart
class UserStreamEndpoint extends FirebaseStreamEndpoint<UserResponseDto> {
	@override
	String get path => 'users';

	@override
	UserResponseDto buildResponse(DocumentSnapshot<Map<String, dynamic>> doc) {
		// ...
	}
}

UserStreamEndpoint().streamAll().listen(
	(users) => print(users),
	onError: (Object e) => print(e), // FirebaseBackendStreamException
);
```

O Firestore reporta falhas de listener **pelo canal de erro do stream**, não
lançando na criação — por isso trate sempre em `onError`.

## 🔒 Auth

```dart
final credential = await FirebaseSigninUser().execute(
	FirebaseSigninDto(email: 'a@b.com', password: 'segredo'),
);

await FirebaseSignupUserRequest().execute(
	FirebaseSignupDto(email: 'a@b.com', password: 'segredo', displayName: 'Ana'),
);

await FirebaseSignoutUserRequest().execute();
```

O signup verifica a senha contra a política do projeto, o que custa uma
requisição extra. Passe `enforcePasswordPolicy: false` (ou sobrescreva
`isPasswordStrong`) se você já valida a força da senha.

### Auth Listener

```dart
final listener = FirebaseAuthListener(
	auth: () => goToHome(),
	unauth: () => goToLogin(),
)..start();

// ...
listener.dispose();
```

O `authStateChanges` emite o estado atual assim que você se inscreve, então
`start()` já dispara um dos callbacks de imediato — é o que permite usá-lo para
decidir a tela inicial. Chamar `start()` de novo substitui a subscription
anterior em vez de vazá-la.

## ☁️ Upload de Arquivos

```dart
class UserProfileUpload extends FirebaseUploadToStorage {
	@override
	String get path => 'profile_pictures';
}

final url = await UserProfileUpload().upload(file: arquivo, fileName: 'avatar.png');

// Controle total sobre a posição do objeto:
final url = await UserProfileUpload().upload(
	file: arquivo,
	referenceBuilder: (ref) => ref.child(uid).child('avatar.png'),
);
```

`file` é um `File` (nativo) ou um `Blob` (web); o método detecta a plataforma.

## ⚠️ Tratamento de erros

Todas as exceções do package herdam de `FirebaseBackendException`:

```dart
try {
	await endpoint.findOne(id);
} on FirebaseBackendValidationException catch (e) {
	for (final erro in e.errors) print('${erro.field}: ${erro.validationError}');
} on FirebaseBackendNotFoundException catch (e) {
	print(e.message);
} on FirebaseBackendException catch (e) {
	print(e.message); // qualquer outra falha do package
}
```

As mensagens de erro de auth são pt-BR por padrão e podem ser sobrescritas por
código:

```dart
FirebaseBackend.authErrorMessages = {'wrong-password': 'Incorrect password.'};
```

## 🧪 Testes

O package não acessa `FirebaseFirestore.instance` diretamente: tudo passa por
`FirebaseBackend`, então seus próprios endpoints são testáveis sem um projeto
Firebase real.

```dart
setUp(() => FirebaseBackend.firestore = FakeFirebaseFirestore());
tearDown(FirebaseBackend.reset);

test('busca o usuário', () async {
	await FirebaseBackend.firestore.collection('users').doc('u1').set({'name': 'Ana'});

	final user = await UserGetEndpoint().findOne('u1');

	expect(user.name, 'Ana');
});
```

Também dá para sobrescrever apenas um endpoint, redefinindo o getter
`firestore`, quando precisar de mais de um Firebase app.

Para rodar a suíte do próprio package:

```bash
flutter test
```

## 📦 Sugestão de Organização Modular

Para projetos grandes, recomenda-se separar os endpoints em um package próprio:

```
my_project/
	packages/
		my_endpoints/       # Novo package apenas para endpoints do seu app
	app/
		lib/
			main.dart
```

No `my_endpoints`, você pode importar o `firebase_backend` e criar endpoints
específicos do seu domínio, mantendo o core desacoplado.

## 📝 Contribuindo

Pull requests são bem-vindos! Para bugs, sugestões ou dúvidas, abra uma issue.
Veja o [CONTRIBUTING.md](CONTRIBUTING.md).

## 📚 Mais informações

- [Documentação oficial do Firebase](https://firebase.google.com/docs)
- [Documentação do FlutterFire](https://firebase.flutter.dev/docs/overview/)
