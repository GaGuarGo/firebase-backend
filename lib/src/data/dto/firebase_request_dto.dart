import 'package:firebase_backend/src/domain/error/dto_validation_error.dart';

abstract class FirebaseRequestDto {
  /// Converts the DTO to a JSON-compatible map.
  Map<String, dynamic> toJson();

  /// Returnas as list of validation errors found in the DTO.
  /// DtoValidationError contains the field name and the corresponding validation error message.
  List<DtoValidationError> validationErrors();


  /// Validates the DTO and returns true if it is valid, false otherwise.
  /// This method should check all necessary fields and their constraints.
  /// Must operate in conjunction with `validationErrors()` to provide detailed error information.
  bool validate();
}
