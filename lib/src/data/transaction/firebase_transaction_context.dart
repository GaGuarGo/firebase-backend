import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_not_found_exception.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_transaction_exception.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_validation_exception.dart';

/// The handle a transaction body works against.
///
/// It wraps Firestore's [Transaction] and adds the two things the raw API does
/// not give you:
///
/// * **Read-before-write enforcement.** Firestore requires every read in a
///   transaction to happen before the first write. Breaking that rule
///   otherwise surfaces as an opaque platform error; here it fails fast with
///   [FirebaseBackendTransactionException.readAfterWrite].
/// * **DTO validation.** [set] and [update] run the same validation as the
///   regular endpoints, so an invalid payload aborts the transaction instead
///   of being written.
///
/// Anything not covered here is reachable through [raw].
class FirebaseTransactionContext {
  /// Wraps [transaction], resolving document paths against [firestore].
  FirebaseTransactionContext(this._firestore, this._transaction);

  final FirebaseFirestore _firestore;
  final Transaction _transaction;
  bool _hasWritten = false;

  /// The underlying Firestore transaction.
  ///
  /// Writes issued through this bypass validation and the read-before-write
  /// check, so prefer the methods on this class.
  Transaction get raw => _transaction;

  /// Whether a write has already been staged, which closes the read phase.
  bool get hasWritten => _hasWritten;

  /// A reference to [documentId] in the collection at [path].
  DocumentReference<Map<String, dynamic>> doc(String path, String documentId) =>
      _firestore.collection(path).doc(documentId);

  /// Reads [reference] inside the transaction.
  ///
  /// Throws [FirebaseBackendTransactionException] when called after a write,
  /// and [FirebaseBackendNotFoundException] when the document is missing and
  /// [required] is true. Pass `required: false` to handle absence yourself via
  /// `snapshot.exists`.
  Future<DocumentSnapshot<Map<String, dynamic>>> get(
    DocumentReference<Map<String, dynamic>> reference, {
    bool required = true,
  }) async {
    if (_hasWritten) {
      throw const FirebaseBackendTransactionException.readAfterWrite();
    }

    final snapshot = await _transaction.get(reference);

    if (required && !snapshot.exists) {
      throw FirebaseBackendNotFoundException.forDocument(
        reference.parent.path,
        reference.id,
      );
    }
    return snapshot;
  }

  /// Writes [requestDto] to [reference], creating the document if needed.
  ///
  /// Throws [FirebaseBackendValidationException] if the DTO is invalid, which
  /// aborts the transaction without writing anything.
  void set(
    DocumentReference<Map<String, dynamic>> reference,
    FirebaseRequestDto requestDto, [
    SetOptions? options,
  ]) {
    setRaw(reference, _validated(requestDto), options);
  }

  /// Merges [requestDto] into the existing document at [reference].
  ///
  /// The write fails if the document does not exist.
  void update(
    DocumentReference<Map<String, dynamic>> reference,
    FirebaseRequestDto requestDto,
  ) {
    updateRaw(reference, _validated(requestDto));
  }

  /// Writes [data] to [reference] without going through a DTO.
  ///
  /// Use this for field level operations such as `FieldValue.increment(1)`.
  void setRaw(
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, dynamic> data, [
    SetOptions? options,
  ]) {
    _hasWritten = true;
    _transaction.set(reference, data, options);
  }

  /// Merges [data] into [reference] without going through a DTO.
  void updateRaw(
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, Object?> data,
  ) {
    _hasWritten = true;
    _transaction.update(reference, data);
  }

  /// Deletes the document at [reference].
  void delete(DocumentReference<Map<String, dynamic>> reference) {
    _hasWritten = true;
    _transaction.delete(reference);
  }

  Map<String, dynamic> _validated(FirebaseRequestDto requestDto) {
    if (!requestDto.validate()) {
      throw FirebaseBackendValidationException(requestDto.validationErrors);
    }
    return requestDto.toJson();
  }
}
