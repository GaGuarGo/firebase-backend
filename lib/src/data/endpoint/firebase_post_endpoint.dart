import 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';
import 'package:firebase_backend/src/data/dto/firebase_response_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/domain/error/firebase_request_dto_validation_error.dart';

abstract class FirebasePostEndpoint<
  T extends FirebaseRequestDto,
  R extends FirebaseResponseDto
> {
  /// The Firestore collection path for the endpoint.
  /// [path] is used to specify the collection from which documents will be retrieved.
  /// For example, if your collection is named "users", the path would be "users".
  /// If your collection is nested, you can specify the full path like "users/{userId}/posts".
  String get path;

  /// Builds a response DTO from a Firestore document snapshot.
  /// [docSnapshot] is the Firestore document snapshot retrieved from the collection.
  /// This method should convert the document snapshot into the appropriate response DTO.
  R buildResponse(DocumentReference docRef, T requestDto);

  /// Creates a new document in the Firestore collection.
  /// [requestDto] is the data transfer object containing the data to be stored.
  /// Returns a Future that resolves to the response DTO after the document is created.
  /// Throws a FirebaseRequestDtoValidationError if the request DTO is invalid.
  Future<R> post(T requestDto) async {
    if (requestDto.validate()) {
      final docRef = await FirebaseFirestore.instance
          .collection(path)
          .add(requestDto.toJson());
      return buildResponse(docRef, requestDto);
    }
    throw FirebaseRequestDtoValidationError(requestDto.validationErrors());
  }
}
