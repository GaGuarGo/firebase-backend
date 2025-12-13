import 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';
import 'package:firebase_backend/src/domain/error/dto_validation_error.dart';

class FirebaseSigninDto extends FirebaseRequestDto {
  final String email;
  final String password;

  FirebaseSigninDto({required this.email, required this.password});

  @override
  Map<String, dynamic> toJson() => {};

  @override
  bool validate() {
    if (email.isEmpty) {
      validationErrors.add(
        DtoValidationError(
          field: 'email',
          validationError: 'Email não pode ser vazio',
        ),
      );
      return false;
    }

    if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$").hasMatch(email)) {
      validationErrors.add(
        DtoValidationError(
          field: 'email',
          validationError: 'Email em formato inválido',
        ),
      );
      return false;
    }

    if (password.isEmpty) {
      validationErrors.add(
        DtoValidationError(
          field: 'password',
          validationError: 'Password não pode ser vazio',
        ),
      );
      return false;
    }
    return true;
  }
}
