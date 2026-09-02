import 'package:firebase_backend/src/domain/validation/validatable.dart';
import 'package:firebase_backend/src/domain/validation/validators.dart';

/// Details for creating a new email and password account.
class FirebaseSignupDto extends Validatable {
  /// Creates the details to sign up with.
  FirebaseSignupDto({
    required this.email,
    required this.password,
    this.displayName,
  });

  /// The email to register.
  final String email;

  /// The password to register.
  ///
  /// Only checked for emptiness here; strength is verified against the
  /// project's password policy by [FirebaseSignupUserRequest].
  final String password;

  /// Optional display name to set on the new account.
  final String? displayName;

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

    final name = displayName;
    if (name != null && name.isNotEmpty && name.length < 3) {
      addError('displayName', 'Name deve ter pelo menos 3 caracteres');
    }
  }
}
