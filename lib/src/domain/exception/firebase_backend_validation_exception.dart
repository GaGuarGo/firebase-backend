import 'package:firebase_backend/src/domain/exception/firebase_backend_exception.dart';
import 'package:firebase_backend/src/domain/validation/dto_validation_error.dart';

/// Thrown when a DTO fails validation, before any Firebase call is made.
///
/// [errors] lists every field that failed, not just the first one.
class FirebaseBackendValidationException extends FirebaseBackendException {
  /// Creates an exception carrying the field level [errors] that were found.
  ///
  /// The list is copied, so it stays intact even if the DTO is validated again
  /// afterwards.
  FirebaseBackendValidationException(Iterable<DtoValidationError> errors)
    : errors = List.unmodifiable(errors),
      super(_format(errors));

  /// Every field level failure found on the DTO.
  final List<DtoValidationError> errors;

  static String _format(Iterable<DtoValidationError> errors) {
    if (errors.isEmpty) return 'Nenhum erro de validação encontrado.';
    final buffer = StringBuffer('Erros de validação encontrados no DTO:');
    for (final error in errors) {
      buffer.write(
        '\n- Campo: ${error.field} | Erro: ${error.validationError}',
      );
    }
    return buffer.toString();
  }
}
