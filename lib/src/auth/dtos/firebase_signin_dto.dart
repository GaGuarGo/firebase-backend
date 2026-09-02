import 'package:firebase_backend/src/domain/validation/validatable.dart';
import 'package:firebase_backend/src/domain/validation/validators.dart';

/// Credentials for an email and password sign-in.
class FirebaseSigninDto extends Validatable {
  /// Creates the credentials to sign in with.
  FirebaseSigninDto({required this.email, required this.password});

  /// The account email.
  final String email;

  /// The account password.
  final String password;

  @override
  void onValidate() {
    if (email.isEmpty) {
      addError('email', 'Email não pode ser vazio');
    } else if (!isValidEmail(email)) {
      addError('email', 'Email em formato inválido');
    }

    if (password.isEmpty) {
      addError('password', 'Password não pode ser vazio');
    }
  }
}
