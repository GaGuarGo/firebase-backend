import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/data/dto/firebase_response_dto.dart';
import 'package:firebase_backend/src/domain/error/firebase_no_document_found_error.dart';

abstract class FirebaseGetEndpoint<R extends FirebaseResponseDto> {

  /// The Firestore collection path for the endpoint.
  /// [path] is used to specify the collection from which documents will be retrieved.
  /// For example, if your collection is named "users", the path would be "users".
  /// If your collection is nested, you can specify the full path like "users/{userId}/posts".
  String get path;


  /// Builds a response DTO from a Firestore document snapshot.
  /// [docSnapshot] is the Firestore document snapshot retrieved from the collection.
  /// This method should convert the document snapshot into the appropriate response DTO.
  R buildResponse(DocumentSnapshot docSnapshot);


  /// Retrieves a single document by its ID from the Firestore collection.
  /// [documentId] is the ID of the document to be retrieved.
  /// Returns a Future that resolves to the response DTO if the document is found.
  /// Throws a FirebaseNoDocumentFoundError if the document does not exist.
  Future<R> findOne(String documentId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection(path)
        .doc(documentId)
        .get();

    if (docSnapshot.exists) {
      return buildResponse(docSnapshot);
    }
    return throw FirebaseNoDocumentFoundError(
      'Document with ID $documentId not found in $path',
    );
  }


  /// Retrieves all documents from the Firestore collection.
  /// Returns a Future that resolves to a list of response DTOs representing all documents in the collection.
  /// Each document is converted to a response DTO using the buildResponse method.
  Future<List<R>> findAll() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(path)
        .get();

    return querySnapshot.docs.map((doc) => buildResponse(doc)).toList();
  }
}
