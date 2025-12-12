// ignore_for_file: public_member_api_docs, sort_constructors_first

class DtoValidationError {
  String field;
  String validationError;
  DtoValidationError({required this.field, required this.validationError});

  @override
  String toString() =>
      'DtoValidationError(field: $field, validationError: $validationError)';
}
