String firebaseAuthErrorMessage(String code) {
	switch (code) {
    case 'invalid-credential':
      return 'As credenciais fornecidas são inválidas.';
		case 'invalid-email':
			return 'O e-mail informado é inválido.';
		case 'user-disabled':
			return 'Esta conta foi desativada.';
		case 'user-not-found':
			return 'Usuário não encontrado.';
		case 'wrong-password':
			return 'Senha incorreta.';
		case 'email-already-in-use':
			return 'Este e-mail já está em uso.';
		case 'operation-not-allowed':
			return 'Operação não permitida. Entre em contato com o suporte.';
		case 'too-many-requests':
			return 'Muitas tentativas. Tente novamente mais tarde.';
		case 'network-request-failed':
			return 'Falha de rede. Verifique sua conexão.';
		case 'weak-password':
			return 'A senha é muito fraca.';
		default:
			return 'Ocorreu um erro desconhecido. Código: $code';
	}
}
