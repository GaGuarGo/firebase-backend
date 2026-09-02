import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:firebase_backend/src/domain/exception/firebase_backend_exception.dart';
import 'package:firebase_backend/src/handlers/firebase_auth_code_error_handler.dart';

/// Wraps a [FirebaseAuthException] with a user facing message.
///
/// Named with the `FirebaseBackend` prefix on purpose: `FirebaseAuthException`
/// is already taken by `package:firebase_auth`, which callers usually import
/// alongside this package.
class FirebaseBackendAuthException extends FirebaseBackendException {
  /// Wraps [cause], resolving its message through [firebaseAuthErrorMessage].
  FirebaseBackendAuthException(this.cause)
    : super(firebaseAuthErrorMessage(cause.code));

  /// The original exception thrown by `package:firebase_auth`.
  final FirebaseAuthException cause;

  /// The Firebase Auth error code, for example `wrong-password`.
  String get code => cause.code;
}
