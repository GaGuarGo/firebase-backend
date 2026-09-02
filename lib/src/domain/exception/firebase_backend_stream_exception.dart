import 'package:firebase_backend/src/domain/exception/firebase_backend_exception.dart';

/// Thrown into a stream when a Firestore listener fails.
///
/// Firestore reports listener failures as stream errors rather than by
/// throwing, so this arrives through `onError` / `catchError` on the
/// subscription, never from the call that created the stream.
class FirebaseBackendStreamException extends FirebaseBackendException {
  /// Creates a stream exception described by [message], wrapping [cause].
  const FirebaseBackendStreamException(super.message, {this.cause});

  /// The underlying error reported by Firestore, when there is one.
  final Object? cause;
}
