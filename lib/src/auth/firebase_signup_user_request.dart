import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_backend/src/auth/dtos/firebase_signup_dto.dart';
import 'package:firebase_backend/src/auth/firebase_auth_request.dart';
import 'package:firebase_backend/src/domain/error/dto_validation_error.dart';
import 'package:firebase_backend/src/domain/error/firebase_auth_error.dart';
import 'package:firebase_backend/src/domain/error/firebase_request_dto_validation_error.dart';

/// Creates a Firebase user sign-up request.
/// This class implements the [FirebaseAuthRequest] interface to handle user
/// sign-up operations using Firebase Authentication.
class FirebaseSignupUserRequest
    implements FirebaseAuthRequest<UserCredential, FirebaseSignupDto> {
  @override
  Future<UserCredential> execute(FirebaseSignupDto dto) async {
    if (!dto.validate()) {
      throw FirebaseRequestDtoValidationError(dto.validationErrors);
    }

    if (!(await FirebaseAuth.instance.validatePassword(
      FirebaseAuth.instance,
      dto.password!,
    )).isValid) {
      dto.validationErrors.add(
        DtoValidationError(
          field: 'password',
          validationError: 'Senha não atende aos requisitos de segurança.',
        ),
      );
      throw FirebaseRequestDtoValidationError(dto.validationErrors);
    }

    late UserCredential user;

    try {
      user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: dto.email!,
        password: dto.password!,
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthError(e);
    }

    if (dto.displayName != null) {
      await user.user?.updateDisplayName(dto.displayName);
    }

    return user;
  }
}
