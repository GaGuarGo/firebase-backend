import 'package:firebase_backend/src/domain/validation/dto_validation_error.dart';
import 'package:flutter/foundation.dart' show protected;

/// Anything that can validate itself and report which fields are wrong.
///
/// Subclasses implement [onValidate] and record failures with [addError]; the
/// [validate] template handles the bookkeeping. Unlike a hand written
/// `validate()`, [onValidate] should **not** stop at the first problem — record
/// every failure so the caller can show them all at once:
///
/// ```dart
/// class SignupDto extends FirebaseRequestDto {
///   @override
///   void onValidate() {
///     if (email.isEmpty) addError('email', 'Email não pode ser vazio');
///     if (password.length < 8) addError('password', 'Mínimo de 8 caracteres');
///   }
/// }
/// ```
abstract class Validatable {
  final List<DtoValidationError> _validationErrors = [];

  /// Field level failures found by the last [validate] call.
  ///
  /// Empty until [validate] runs. The returned list is unmodifiable; use
  /// [addError] from [onValidate] to populate it.
  List<DtoValidationError> get validationErrors =>
      List.unmodifiable(_validationErrors);

  /// Records that [field] is invalid because of [validationError].
  @protected
  void addError(String field, String validationError) => _validationErrors.add(
    DtoValidationError(field: field, validationError: validationError),
  );

  /// Checks every field, calling [addError] for each problem found.
  ///
  /// Implementations must not throw and must not return early: collecting all
  /// failures is the point.
  @protected
  void onValidate();

  /// Validates this object and returns whether it is free of errors.
  ///
  /// Clears [validationErrors] first, so calling this repeatedly (which
  /// happens on every transaction retry) never accumulates duplicates.
  ///
  /// Do not override this; implement [onValidate] instead.
  bool validate() {
    _validationErrors.clear();
    onValidate();
    return _validationErrors.isEmpty;
  }
}
