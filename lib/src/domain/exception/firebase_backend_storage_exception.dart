import 'package:firebase_backend/src/domain/exception/firebase_backend_exception.dart';

/// Thrown when a Firebase Storage operation fails.
class FirebaseBackendStorageException extends FirebaseBackendException {
  /// Creates a storage exception described by [message], keeping the Firebase
  /// error [code] when one is available.
  const FirebaseBackendStorageException(super.message, {this.code});

  /// The Firebase Storage error code (for example `unauthorized`), if known.
  final String? code;
}
