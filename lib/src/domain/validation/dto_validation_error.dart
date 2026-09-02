/// A single field level validation failure.
///
/// This is a value object describing *what* is wrong with one field, not a
/// throwable. DTOs collect these in `validationErrors`, and
/// [FirebaseBackendValidationException] carries the whole list when a request
/// is rejected.
class DtoValidationError {
  /// Creates a validation error for [field] described by [validationError].
  const DtoValidationError({
    required this.field,
    required this.validationError,
  });

  /// Name of the offending field.
  final String field;

  /// Why the field is invalid.
  final String validationError;

  @override
  String toString() =>
      'DtoValidationError(field: $field, validationError: $validationError)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DtoValidationError &&
          other.field == field &&
          other.validationError == validationError;

  @override
  int get hashCode => Object.hash(field, validationError);
}
