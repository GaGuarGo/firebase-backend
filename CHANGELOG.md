## 0.1.0

Primeira versão com suíte de testes e suporte a transactions. Esta versão tem
**breaking changes**; veja o guia de migração no fim da seção.

### Adicionado
- `FirebaseTransactionEndpoint` e `FirebaseTransactionContext`: leitura e
  escrita atômicas com validação de DTO e verificação da regra
  leia-antes-de-escrever do Firestore.
- Parâmetro opcional `transaction` em `findOne`, `post`, `update` e `delete`,
  para reusar endpoints existentes dentro de uma transaction.
- `FirebaseBackend`: ponto único de injeção de `FirebaseFirestore`,
  `FirebaseAuth` e `FirebaseStorage`, o que torna o package testável sem um
  projeto Firebase real.
- Mixin `FirebaseEndpoint` com `path`, `firestore`, `collection` e `doc()`,
  eliminando a duplicação entre os endpoints.
- Suíte com 110 testes e CI rodando formatação, análise, testes com cobertura e
  `pub publish --dry-run`.
- `post` aceita `documentId`, permitindo gravar em `users/{uid}`.
- `streamAll` aceita `queryBuilder`, como `findAll` já aceitava.
- `delete` aceita `ensureExists: false` para evitar a leitura cobrada antes de
  cada exclusão.
- `FirebaseSignupUserRequest` aceita `enforcePasswordPolicy` e expõe
  `isPasswordStrong`, evitando o round-trip de rede da política de senha.
- App Check agora ativa provider em Android (Play Integrity) e Apple (Device
  Check), não só na web.
- `FirebaseBackend.authErrorMessages` permite sobrescrever as mensagens de erro
  de autenticação.

### Corrigido
- **Streams não reportavam erros.** O `try/catch` envolvia apenas a construção
  do stream, que nunca lança; falhas do Firestore chegam pelo canal de erro e
  escapavam sem tratamento. Agora viram `FirebaseBackendStreamException`.
- **`validationErrors` acumulava duplicatas.** A lista nunca era limpa, então
  validar o mesmo DTO duas vezes duplicava os erros — o que acontece a cada
  retry de transaction. E como todo `validate()` retornava no primeiro erro, só
  um campo era reportado por vez; agora todos são.
- **`FirebaseAuthListener.dispose()` podia estourar.** A subscription era um
  campo `late` não-nulável, então descartar antes de iniciar lançava
  `LateInitializationError`. Iniciar duas vezes também vazava a primeira
  subscription.
- `update` em documento inexistente agora lança
  `FirebaseBackendNotFoundException` em vez de um `FirebaseException` cru,
  consistente com `delete` (sem custo de leitura extra).
- Falhas de upload preservam o `code` do `FirebaseException`, e falhas ao montar
  a referência (inclusive dentro de um `referenceBuilder`) também são mapeadas.
- `signOut` mapeia `FirebaseAuthException` como os demais métodos de auth.
- `displayName` no signup é aplicado dentro do `try` e seguido de `reload()`,
  então a credencial retornada já vem com o nome.
- Removido código morto no fallback de nome de arquivo do upload, e a
  dependência de `cloud_firestore` só para gerar um timestamp.

### Alterado (breaking)

| Antes | Agora |
|---|---|
| `intiFirebaseBackend(...)` | `initFirebaseBackend(...)` |
| `FirebaseAuthError` | `FirebaseBackendAuthException` |
| `FirebaseNoDocumentFoundError` | `FirebaseBackendNotFoundException` |
| `FirebaseRequestDtoValidationError` | `FirebaseBackendValidationException` |
| `FirebaseStorageError` | `FirebaseBackendStorageException` |
| `FirebaseStreamError` | `FirebaseBackendStreamException` |
| `listener.authListener()` | `listener.start()` |
| `signOutRequest.execute(dto)` | `signOutRequest.execute()` |
| `bool validate()` no seu DTO | `void onValidate()` com `addError(...)` |
| `FirebaseUpdateEndpoint<T>` | `FirebaseUpdateEndpoint<T, R>`, com `buildResponse` retornando `R` |
| DTOs de auth estendiam `FirebaseRequestDto` | estendem `Validatable` (sem `toJson` obrigatório) |

Todas as exceções agora herdam de `FirebaseBackendException`, então
`on FirebaseBackendException catch (e)` cobre qualquer falha do package.

O prefixo `FirebaseBackend` nas exceções é proposital:
`FirebaseAuthException` já é o nome da classe do `package:firebase_auth`, que
normalmente é importado junto.

**Migrando os DTOs.** `validate()` agora é um template method que limpa os erros
e chama `onValidate()`. Troque o retorno por chamadas a `addError` e não pare no
primeiro erro:

```dart
// antes
@override
bool validate() {
  if (email.isEmpty) {
    validationErrors.add(DtoValidationError(field: 'email', validationError: '...'));
    return false;
  }
  return true;
}

// agora
@override
void onValidate() {
  if (email.isEmpty) addError('email', '...');
}
```

## 0.0.8
- Atualização das docs

## 0.0.7
- Configuração para uso de streams para valor único ou para um array
- Ajuste do FirebaseGetEndpoint para o uso de queryBuilders para filtrar a busca na query
- Configuração para fazer upload do bucket

## 0.0.6
- Adição de mais um caso no error handler do auth

## 0.0.5
- Adição dos dtos de auth no export

## 0.0.4
- Adição dos endpoints de auth no export

## 0.0.3
- Fix no response DTO

## 0.0.2
- Adição do método de signOut

## 0.0.1
- Abstração de endpoints para Firestore (GET, POST, UPDATE, DELETE)
- Suporte a DTOs de request e response
- Entidades de domínio separadas dos DTOs
- Validação customizada de DTOs
- Tratamento de erros do Firebase Auth e Firestore
- Função utilitária para inicialização do Firebase
- Sugestão de organização modular para integração em outros projetos
