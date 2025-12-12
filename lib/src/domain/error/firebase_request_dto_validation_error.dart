import 'package:firebase_backend/src/domain/error/dto_validation_error.dart';

class FirebaseRequestDtoValidationError implements Exception {
  final List<DtoValidationError> errors;
  FirebaseRequestDtoValidationError(this.errors);

  @override
  String toString() {
    if (errors.isEmpty) {
      return 'FirebaseRequestDtoValidationError: Nenhum erro de validação encontrado.';
    }
    final buffer = StringBuffer('Erros de validação encontrados no DTO:\n');
    for (final error in errors) {
      buffer.writeln('- Campo: ${error.field} | Erro: ${error.validationError}');
    }
    return buffer.toString();
  }
}
