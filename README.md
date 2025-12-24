
# Firebase Backend

> Solução modular para abstração de endpoints, DTOs, entidades e integração com Firebase Auth/Firestore em Dart/Flutter.

## ✨ Features

- Abstração de endpoints REST/Firestore (GET, POST, STREAM, UPLOAD)
- DTOs e entidades desacopladas
- Validação e tratamento de erros customizados
- Handlers para códigos de erro do Firebase Auth
- Fácil integração com projetos Flutter/Dart

## 🚀 Getting Started


1. **Adicione o pacote ao seu projeto:**

	 No `pubspec.yaml` do projeto que for integrar:
	 ```yaml
	 dependencies:
		 firebase_backend:
			 git:
				 url: https://github.com/Flownex/firebase-backend.git
				 ref: main # ou a branch/tag desejada
	 ```

2. **Configure o Firebase no seu projeto:**
	- Utilize a função de inicialização fornecida pelo próprio package (`initializeFirebase` );
	- Para detalhes avançados, consulte também a [documentação oficial do Firebase para Flutter](https://firebase.flutter.dev/docs/overview/).

3. **Implemente seus DTOs, entidades e endpoints:**
	- Crie DTOs herdando de `FirebaseRequestDto` e `FirebaseResponseDto`;
	- Crie entidades de domínio para separar regras de negócio;
	- Implemente endpoints herdando de `FirebaseGetEndpoint`, `FirebasePostEndpoint`, `FirebaseStreamEndpoint`;
	- Para upload de arquivos, utilize `FirebaseUploadStorage`.
## 🔄 Stream Endpoint Example

O package fornece o `FirebaseStreamEndpoint` para escutar mudanças em tempo real de documentos ou coleções do Firestore.

```dart
import 'package:firebase_backend/firebase_backend.dart';

class UserStreamEndpoint extends FirebaseStreamEndpoint<UserResponseDto> {
	@override
	String get path => 'users';

	@override
	UserResponseDto buildResponse(DocumentSnapshot doc) {
		// ...
	}
}

// Uso:
final endpoint = UserStreamEndpoint();
final stream = endpoint.stream();
stream.listen((user) {
	// Atualizações em tempo real
});
```

## 📦 Sugestão de Organização Modular

Para projetos grandes, recomenda-se separar os endpoints em um package próprio, por exemplo:

```
my_project/
	packages/
		my_endpoints/       # Novo package apenas para endpoints do seu app
	app/
		lib/
			main.dart
```

No `my_endpoints`, você pode importar o `firebase_backend` e criar endpoints específicos do seu domínio, mantendo o core desacoplado.


## 🔒 Auth Listener Example

O package fornece o `FirebaseAuthListener` para escutar mudanças de autenticação do usuário em tempo real. Exemplo de uso:

```dart
import 'package:firebase_backend/firebase_backend.dart';

final authListener = FirebaseAuthListener(
	auth: () {
		print('Usuário autenticado!');
		// Ações quando o usuário faz login
	},
	unauth: () {
		print('Usuário deslogado!');
		// Ações quando o usuário faz logout
	},
);

// Inicie o listener (ex: no initState de um widget ou no main)
@override
void initState() {
	super.initState();
	authListener.authListener();
}

// Não esqueça de cancelar o listener ao descartar o widget
@override
void dispose() {
	authListener.dispose();
	super.dispose();
}
```


## 🛠️ Usage Example

```dart
import 'package:firebase_backend/firebase_backend.dart';

class UserSignUpDto extends FirebaseRequestDto {
	final String email;
	final String password;
	// ...
	// Implementação dos métodos obrigatórios
}

class UserResponseDto extends FirebaseResponseDto {
	// ...
}

// Exemplo GET Endpoint
class UserGetEndpoint extends FirebaseGetEndpoint<UserResponseDto> {
	@override
	String get path => 'users';

	@override
	UserResponseDto buildResponse(DocumentSnapshot doc) {
		// ...
	}
}

// Exemplo POST Endpoint
class UserEndpoint extends FirebasePostEndpoint<UserSignUpDto, UserResponseDto> {
	@override
	String get path => 'users';

	@override
	UserResponseDto buildResponse(DocumentReference docRef, UserSignUpDto dto) {
		// ...
	}
}

// Uso:
final getEndpoint = UserGetEndpoint();
final user = await getEndpoint.get('userId');

final postEndpoint = UserEndpoint();
final response = await postEndpoint.post(UserSignUpDto(email: 'a@b.com', password: '123456'));
## ☁️ Upload de Arquivos (FirebaseUploadStorage)

Para upload de arquivos (compatível com web e mobile), utilize a classe `FirebaseUploadStorage`:

```dart
import 'package:firebase_backend/firebase_backend.dart';

class UserProfileUpload extends FirebaseUploadStorage {
	@override
	String get path => 'profile_pictures';
}

// Uso (mobile):
final uploader = UserProfileUpload();
final url = await uploader.upload(file: arquivoFile, fileName: 'avatar.png');

// Uso (web):
// file deve ser um objeto html.File
final urlWeb = await uploader.upload(file: arquivoHtmlFile, fileName: 'avatar.png');
```

O método `upload` detecta automaticamente se está rodando na web ou mobile e faz o upload corretamente para o Firebase Storage.
```

## 📝 Contribuindo

Pull requests são bem-vindos! Para bugs, sugestões ou dúvidas, abra uma issue.

## 📚 Mais informações

- [Documentação oficial do Firebase](https://firebase.google.com/docs)
- [Documentação do FlutterFire](https://firebase.flutter.dev/docs/overview/)

