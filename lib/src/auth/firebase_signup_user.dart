import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_backend/src/data/dto/firebase_signup_dto.dart';
import 'package:firebase_backend/src/domain/error/firebase_request_dto_validation_error.dart';

class FirebaseSignupUser {
  Future<UserCredential> signUpWithEmailAndPassword(
    FirebaseSignupDto dto,
  ) async {
    if (!dto.validate()) {
      throw FirebaseRequestDtoValidationError(dto.validationErrors);
    }

    final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: dto.email!,
      password: dto.password!,
    );

    if (dto.displayName != null) {
      await user.user?.updateDisplayName(dto.displayName);
    }

    return user;
  }
}
