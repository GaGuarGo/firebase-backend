import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/core/firebase_endpoint.dart';
import 'package:firebase_backend/src/data/dto/firebase_response_dto.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_not_found_exception.dart';

/// Reads documents from the collection at [path].
abstract class FirebaseGetEndpoint<R extends FirebaseResponseDto>
    with FirebaseEndpoint {
  /// Converts a Firestore document into the response DTO for this endpoint.
  R buildResponse(DocumentSnapshot<Map<String, dynamic>> docSnapshot);

  /// Reads the document [documentId].
  ///
  /// Pass [transaction] to read inside a running transaction, which makes the
  /// read part of the atomic unit. Firestore requires all transactional reads
  /// to happen before the first write.
  ///
  /// Throws [FirebaseBackendNotFoundException] when the document is missing.
  Future<R> findOne(String documentId, {Transaction? transaction}) async {
    final ref = doc(documentId);
    final docSnapshot = transaction != null
        ? await transaction.get(ref)
        : await ref.get();

    if (!docSnapshot.exists) {
      throw FirebaseBackendNotFoundException.forDocument(path, documentId);
    }
    return buildResponse(docSnapshot);
  }

  /// Reads every document in the collection, newest query semantics first.
  ///
  /// Use [queryBuilder] to filter, order or limit:
  ///
  /// ```dart
  /// await endpoint.findAll(
  ///   queryBuilder: (q) => q.where('active', isEqualTo: true).limit(20),
  /// );
  /// ```
  ///
  /// There is no transactional variant: Firestore transactions can only read
  /// individual documents, so use [findOne] inside a transaction.
  Future<List<R>> findAll({
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
    queryBuilder,
  }) async {
    Query<Map<String, dynamic>> query = collection;

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    final snapshot = await query.get();

    return snapshot.docs.map(buildResponse).toList();
  }
}
