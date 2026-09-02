import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/core/firebase_endpoint.dart';
import 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';
import 'package:firebase_backend/src/data/dto/firebase_response_dto.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_validation_exception.dart';

/// Creates documents in the collection at [path].
abstract class FirebasePostEndpoint<
  T extends FirebaseRequestDto,
  R extends FirebaseResponseDto
>
    with FirebaseEndpoint {
  /// Builds the response for a document just written at [docRef].
  R buildResponse(DocumentReference<Map<String, dynamic>> docRef, T requestDto);

  /// Writes [requestDto] as a new document.
  ///
  /// Without [documentId] the id is generated. Pass [documentId] to control it,
  /// which is what you want for collections keyed by an external id such as
  /// `users/{uid}`; note this overwrites any existing document at that id.
  ///
  /// Pass [transaction] to write inside a running transaction.
  ///
  /// Throws [FirebaseBackendValidationException] before touching Firebase when
  /// the DTO is invalid.
  Future<R> post(
    T requestDto, {
    String? documentId,
    Transaction? transaction,
  }) async {
    if (!requestDto.validate()) {
      throw FirebaseBackendValidationException(requestDto.validationErrors);
    }

    final docRef = documentId == null ? collection.doc() : doc(documentId);
    final json = requestDto.toJson();

    if (transaction != null) {
      transaction.set(docRef, json);
    } else {
      await docRef.set(json);
    }

    return buildResponse(docRef, requestDto);
  }
}
