import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/core/firebase_endpoint.dart';
import 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';
import 'package:firebase_backend/src/data/transaction/firebase_transaction_context.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_exception.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_transaction_exception.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_validation_exception.dart';

/// Runs a read-then-write unit of work atomically.
///
/// Implement [execute] with the body of the transaction and call [run] to
/// commit it. Reads and writes go through [FirebaseTransactionContext], which
/// enforces Firestore's read-before-write rule and validates DTOs.
///
/// ```dart
/// class TransferFunds extends FirebaseTransactionEndpoint<TransferDto, void> {
///   @override
///   String get path => 'accounts';
///
///   @override
///   Future<void> execute(FirebaseTransactionContext ctx, TransferDto dto) async {
///     final from = await ctx.get(doc(dto.fromId));   // every read comes first
///     final to = await ctx.get(doc(dto.toId));
///
///     final balance = from.data()!['balance'] as int;
///     if (balance < dto.amount) throw InsufficientFunds();
///
///     ctx.updateRaw(from.reference, {'balance': balance - dto.amount});
///     ctx.updateRaw(to.reference, {'balance': FieldValue.increment(dto.amount)});
///   }
/// }
///
/// await TransferFunds().run(TransferDto(from: 'a', to: 'b', amount: 10));
/// ```
abstract class FirebaseTransactionEndpoint<T extends FirebaseRequestDto, R>
    with FirebaseEndpoint {
  /// The body of the transaction.
  ///
  /// **This may run several times.** Firestore retries the whole body when a
  /// document it read is modified concurrently, so keep it free of side effects
  /// outside [ctx]: no logging that must happen once, no mutating outer state,
  /// no sending notifications. Do that after [run] returns.
  ///
  /// Every read must happen before the first write; [ctx] enforces it.
  ///
  /// Throwing from here aborts the transaction and nothing is committed. The
  /// exception propagates out of [run] unchanged.
  Future<R> execute(FirebaseTransactionContext ctx, T dto);

  /// Validates [dto], then runs [execute] atomically and returns its result.
  ///
  /// [timeout] bounds the total execution time and [maxAttempts] the number of
  /// attempts on contention; both default to Firestore's own values.
  ///
  /// Throws [FirebaseBackendValidationException] if [dto] is invalid and
  /// [FirebaseBackendTransactionException] if the transaction itself fails, for
  /// example when it exhausts [maxAttempts]. Exceptions thrown by [execute]
  /// propagate untouched.
  Future<R> run(
    T dto, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    if (!dto.validate()) {
      throw FirebaseBackendValidationException(dto.validationErrors);
    }

    try {
      return await firestore.runTransaction(
        (transaction) =>
            execute(FirebaseTransactionContext(firestore, transaction), dto),
        timeout: timeout,
        maxAttempts: maxAttempts,
      );
    } on FirebaseBackendException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirebaseBackendTransactionException(
        'Transaction on $path failed: ${e.message ?? e.code}',
        code: e.code,
      );
    }
  }
}
