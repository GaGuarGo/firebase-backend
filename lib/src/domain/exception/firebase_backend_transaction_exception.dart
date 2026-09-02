import 'package:firebase_backend/src/domain/exception/firebase_backend_exception.dart';

/// Thrown when a Firestore transaction fails or is used incorrectly.
class FirebaseBackendTransactionException extends FirebaseBackendException {
  /// Creates a transaction exception described by [message], keeping the
  /// Firebase error [code] when one is available.
  const FirebaseBackendTransactionException(super.message, {this.code});

  /// The Firebase error code (for example `aborted`), if known.
  ///
  /// Set to `read-after-write` when this package detected the misuse itself
  /// rather than Firestore reporting it.
  final String? code;

  /// Signals a read issued after a write inside the same transaction.
  ///
  /// Firestore requires every read to happen before the first write; breaking
  /// that rule otherwise surfaces as an opaque platform error.
  const FirebaseBackendTransactionException.readAfterWrite()
    : this(
        'Todas as leituras devem acontecer antes da primeira escrita dentro '
        'de uma transaction. Mova as chamadas de get() para o início do '
        'método execute().',
        code: 'read-after-write',
      );
}
