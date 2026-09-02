import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/core/firebase_endpoint.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_not_found_exception.dart';

/// Deletes documents from the collection at [path].
abstract class FirebaseDeleteEndpoint with FirebaseEndpoint {
  /// Deletes the document [documentId].
  ///
  /// By default this reads the document first so a missing one fails with
  /// [FirebaseBackendNotFoundException] instead of succeeding silently, which
  /// is how Firestore behaves on its own. That read is billed; pass
  /// `ensureExists: false` to delete without it when you do not need the check.
  ///
  /// Pass [transaction] to delete inside a running transaction; the existence
  /// check is skipped there, since a transactional read must precede every
  /// write.
  Future<void> delete(
    String documentId, {
    bool ensureExists = true,
    Transaction? transaction,
  }) async {
    final docRef = doc(documentId);

    if (transaction != null) {
      transaction.delete(docRef);
      return;
    }

    if (ensureExists && !(await docRef.get()).exists) {
      throw FirebaseBackendNotFoundException.forDocument(path, documentId);
    }

    await docRef.delete();
  }
}
