import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/core/firebase_endpoint.dart';
import 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';
import 'package:firebase_backend/src/data/dto/firebase_response_dto.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_not_found_exception.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_validation_exception.dart';

/// Updates documents in the collection at [path].
///
/// Use [FirebaseNoResponseDto] as `R` when there is nothing to return.
abstract class FirebaseUpdateEndpoint<
  T extends FirebaseRequestDto,
  R extends FirebaseResponseDto
>
    with FirebaseEndpoint {
  /// Builds the response for the document just updated at [docRef].
  R buildResponse(DocumentReference<Map<String, dynamic>> docRef, T requestDto);

  /// Merges [requestDto] into the document [documentId].
  ///
  /// Pass [transaction] to update inside a running transaction.
  ///
  /// Throws [FirebaseBackendValidationException] when the DTO is invalid and
  /// [FirebaseBackendNotFoundException] when the document does not exist. The
  /// missing document is detected from Firestore's own `not-found` response,
  /// so this costs no extra read.
  Future<R> update(
    String documentId,
    T requestDto, {
    Transaction? transaction,
  }) async {
    if (!requestDto.validate()) {
      throw FirebaseBackendValidationException(requestDto.validationErrors);
    }

    final docRef = doc(documentId);
    final json = requestDto.toJson();

    if (transaction != null) {
      transaction.update(docRef, json);
    } else {
      try {
        await docRef.update(json);
      } on FirebaseException catch (e) {
        if (e.code == 'not-found') {
          throw FirebaseBackendNotFoundException.forDocument(path, documentId);
        }
        rethrow;
      }
    }

    return buildResponse(docRef, requestDto);
  }
}
