import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';
import 'package:firebase_backend/src/domain/error/firebase_request_dto_validation_error.dart';

abstract class FirebaseUpdateEndpoint<T extends FirebaseRequestDto> {
  /// The Firestore collection path for the endpoint.
  /// [path] is used to specify the collection from which documents will be retrieved.
  /// For example, if your collection is named "users", the path would be "users".
  /// If your collection is nested, you can specify the full path like "users/{userId}/posts".
  String get path;

  /// Builds a response DTO from a Firestore document snapshot.
  /// [docSnapshot] is the Firestore document snapshot retrieved from the collection.
  /// This method should convert the document snapshot into the appropriate response DTO.
  void buildResponse(String documentId, T requestDto);


  /// Updates an existing document in the Firestore collection.
  /// [documentId] is the ID of the document to be updated.
  /// [requestDto] is the data transfer object containing the updated data.
  /// Returns a Future that resolves to void after the document is updated.
  /// Throws a FirebaseRequestDtoValidationError if the request DTO is invalid.
  Future<void> update(String documentId, T requestDto) async {
    if (requestDto.validate()) {
      await FirebaseFirestore.instance
          .collection(path)
          .doc(documentId)
          .update(requestDto.toJson());
      return buildResponse(documentId, requestDto);
    }
    throw FirebaseRequestDtoValidationError(requestDto.validationErrors);
  }
}
