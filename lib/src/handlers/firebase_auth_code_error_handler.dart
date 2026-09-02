import 'package:firebase_backend/src/firebase_backend_config.dart';

/// Default pt-BR message for each Firebase Auth error code.
const Map<String, String> kDefaultFirebaseAuthErrorMessages = {
  'invalid-credential': 'As credenciais fornecidas são inválidas.',
  'invalid-email': 'O e-mail informado é inválido.',
  'user-disabled': 'Esta conta foi desativada.',
  'user-not-found': 'Usuário não encontrado.',
  'wrong-password': 'Senha incorreta.',
  'email-already-in-use': 'Este e-mail já está em uso.',
  'operation-not-allowed':
      'Operação não permitida. Entre em contato com o suporte.',
  'too-many-requests': 'Muitas tentativas. Tente novamente mais tarde.',
  'network-request-failed': 'Falha de rede. Verifique sua conexão.',
  'weak-password': 'A senha é muito fraca.',
  'requires-recent-login': 'Faça login novamente para concluir esta operação.',
};

/// Resolves the user facing message for a Firebase Auth error [code].
///
/// Looks up [FirebaseBackend.authErrorMessages] first, so an app can translate
/// or reword any subset of the codes, then falls back to
/// [kDefaultFirebaseAuthErrorMessages].
String firebaseAuthErrorMessage(String code) =>
    FirebaseBackend.authErrorMessages[code] ??
    kDefaultFirebaseAuthErrorMessages[code] ??
    'Ocorreu um erro desconhecido. Código: $code';
