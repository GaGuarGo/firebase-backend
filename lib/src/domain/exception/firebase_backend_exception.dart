/// Base type for every error this package throws.
///
/// Catch it to handle any failure originating from `firebase_backend` without
/// enumerating the individual subtypes:
///
/// ```dart
/// try {
///   await endpoint.findOne(id);
/// } on FirebaseBackendException catch (e) {
///   showError(e.message);
/// }
/// ```
///
/// These are [Exception]s, not [Error]s: they describe recoverable conditions
/// (a missing document, a rejected write, invalid input) that callers are
/// expected to catch.
abstract class FirebaseBackendException implements Exception {
  /// Creates an exception carrying a human readable [message].
  const FirebaseBackendException(this.message);

  /// Human readable description of what went wrong.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}
