import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/domain/error/firebase_no_document_found_error.dart';

abstract class FirebaseDeleteEndpoint {
  /// The Firestore collection path for the endpoint.
  /// [path] is used to specify the collection from which documents will be deleted.
  /// For example, if your collection is named "users", the path would be "users".
  /// If your collection is nested, you can specify the full path like "users/{userId}/posts".
  String get path;

  /// Deletes an existing document in the Firestore collection.
  /// [documentId] is the ID of the document to be deleted.
  /// Returns a Future that resolves to void after the document is deleted.
  Future<void> delete(String documentId) async {
    final doc = FirebaseFirestore.instance.collection(path).doc(documentId);
    final docSnapshot = await doc.get();

    if (!docSnapshot.exists) {
      throw FirebaseNoDocumentFoundError(
        'Document with ID $documentId not found in $path for deletion',
      );
    }

    await docSnapshot.reference.delete();
  }
}
