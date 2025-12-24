import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:firebase_backend/src/domain/error/firebase_stream_error.dart';

/// An abstract class representing a Firebase stream endpoint.
/// It provides methods to stream all documents or a specific document by ID
/// from a Firestore collection.
abstract class FirebaseStreamEndpoint<R extends FirebaseResponseDto> {

  /// The Firestore collection path.
  String get path;

  /// Builds a response object from a Firestore document snapshot.
  /// [doc] The Firestore document snapshot.
  /// Returns an instance of [R] representing the document data.
  R buildResponse(DocumentSnapshot doc);


  /// Streams all documents from the Firestore collection.
  /// Returns a stream of lists of [R] representing the documents.
  /// Throws a [FirebaseStreamError] if streaming fails.
  Stream<List<R>> streamAll() {
    try {
      return FirebaseFirestore.instance.collection(path).snapshots().map((
        snapshot,
      ) {
        return snapshot.docs.map((doc) => buildResponse(doc)).toList();
      });
    } catch (e) {
      throw FirebaseStreamError(
        'Failed to stream all documents from $path: $e',
      );
    }
  }

  /// Streams a specific document by its ID from the Firestore collection.
  /// [id] The ID of the document to stream.
  /// Returns a stream of [R] representing the document data, or null if the
  /// document does not exist.
  /// Throws a [FirebaseStreamError] if streaming fails.
  Stream<R?> streamById(String id) {
    try {
      return FirebaseFirestore.instance
          .collection(path)
          .doc(id)
          .snapshots()
          .map((doc) {
            if (doc.exists) {
              return buildResponse(doc);
            } else {
              return null;
            }
          });
    } catch (e) {
      throw FirebaseStreamError(
        'Failed to stream document with ID $id from $path: $e',
      );
    }
  }
}
