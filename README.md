
# Firebase Backend

> Solução modular para abstração de endpoints, DTOs, entidades e integração com Firebase Auth/Firestore em Dart/Flutter.

## ✨ Features

- Abstração de endpoints REST/Firestore
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
	 - Implemente endpoints herdando de `FirebaseGetEndpoint` e `FirebasePostEndpoint`.

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

class UserEndpoint extends FirebasePostEndpoint<UserSignUpDto, UserResponseDto> {
	@override
	String get path => 'users';

	@override
	UserResponseDto buildResponse(DocumentReference docRef, UserSignUpDto dto) {
		// ...
	}
}

// Uso:
final endpoint = UserEndpoint();
final response = await endpoint.post(UserSignUpDto(email: 'a@b.com', password: '123456'));
```

## 📝 Contribuindo

Pull requests são bem-vindos! Para bugs, sugestões ou dúvidas, abra uma issue.

## 📚 Mais informações

- [Documentação oficial do Firebase](https://firebase.google.com/docs)
- [Documentação do FlutterFire](https://firebase.flutter.dev/docs/overview/)

