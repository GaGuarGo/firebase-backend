// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';
import 'package:firebase_backend/src/domain/error/dto_validation_error.dart';

class FirebaseSignupDto extends FirebaseRequestDto {
  String? email;
  String? password;
  String? displayName;

  FirebaseSignupDto({this.email, this.password, this.displayName});

  @override
  Map<String, dynamic> toJson() => {};

  @override
  bool validate() {
    if (email == null || email!.isEmpty) {
      validationErrors.add(
        DtoValidationError(
          field: 'email',
          validationError: 'Email não pode ser nulo ou vazio',
        ),
      );
      return false;
    }

    if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$").hasMatch(email!)) {
      validationErrors.add(
        DtoValidationError(
          field: 'email',
          validationError: 'Email em formato inválido',
        ),
      );
      return false;
    }

    if (password == null || password!.isEmpty) {
      validationErrors.add(
        DtoValidationError(
          field: 'password',
          validationError: 'Password não pode ser nulo ou vazio',
        ),
      );
      return false;
    }
    return true;
  }
}
