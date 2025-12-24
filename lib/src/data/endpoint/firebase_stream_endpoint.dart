import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:firebase_backend/src/domain/error/firebase_stream_error.dart';

abstract class FirebaseStreamEndpoint<R extends FirebaseResponseDto> {
  String get path;

  R buildResponse(DocumentSnapshot doc);

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
