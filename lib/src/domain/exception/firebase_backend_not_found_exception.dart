import 'package:firebase_backend/src/domain/exception/firebase_backend_exception.dart';

/// Thrown when an operation targets a document that does not exist.
class FirebaseBackendNotFoundException extends FirebaseBackendException {
  /// Creates a not found exception, optionally naming the [documentId] and
  /// collection [path] that were being addressed.
  const FirebaseBackendNotFoundException(
    super.message, {
    this.path,
    this.documentId,
  });

  /// Collection path that was searched, when known.
  final String? path;

  /// Id of the document that was missing, when known.
  final String? documentId;

  /// Builds the standard "not found" message for [documentId] in [path].
  factory FirebaseBackendNotFoundException.forDocument(
    String path,
    String documentId,
  ) => FirebaseBackendNotFoundException(
    'Document with ID $documentId not found in $path',
    path: path,
    documentId: documentId,
  );
}
