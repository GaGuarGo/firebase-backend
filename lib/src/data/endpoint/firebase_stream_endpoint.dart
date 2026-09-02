import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/core/firebase_endpoint.dart';
import 'package:firebase_backend/src/data/dto/firebase_response_dto.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_stream_exception.dart';

/// Listens to the collection at [path] in real time.
///
/// Firestore reports listener failures as **stream errors**, not by throwing
/// from the call that creates the stream. Both methods below therefore surface
/// [FirebaseBackendStreamException] through `onError`:
///
/// ```dart
/// endpoint.streamAll().listen(
///   (items) => ...,
///   onError: (Object e) => ...,  // FirebaseBackendStreamException
/// );
/// ```
abstract class FirebaseStreamEndpoint<R extends FirebaseResponseDto>
    with FirebaseEndpoint {
  /// Converts a Firestore document into the response DTO for this endpoint.
  R buildResponse(DocumentSnapshot<Map<String, dynamic>> doc);

  /// Streams every document in the collection.
  ///
  /// Use [queryBuilder] to filter, order or limit the underlying query.
  Stream<List<R>> streamAll({
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
    queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = collection;

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    return query
        .snapshots()
        .map((snapshot) => snapshot.docs.map(buildResponse).toList())
        .handleError(
          (Object error, StackTrace stackTrace) => Error.throwWithStackTrace(
            FirebaseBackendStreamException(
              'Failed to stream documents from $path: $error',
              cause: error,
            ),
            stackTrace,
          ),
        );
  }

  /// Streams the document [id], emitting `null` while it does not exist.
  Stream<R?> streamById(String id) {
    return doc(id)
        .snapshots()
        .map((snapshot) => snapshot.exists ? buildResponse(snapshot) : null)
        .handleError(
          (Object error, StackTrace stackTrace) => Error.throwWithStackTrace(
            FirebaseBackendStreamException(
              'Failed to stream document with ID $id from $path: $error',
              cause: error,
            ),
            stackTrace,
          ),
        );
  }
}
