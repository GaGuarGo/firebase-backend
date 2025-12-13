import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_backend/src/auth/dtos/firebase_signin_dto.dart';
import 'package:firebase_backend/src/auth/firebase_auth_request.dart';
import 'package:firebase_backend/src/domain/error/firebase_auth_error.dart';
import 'package:firebase_backend/src/domain/error/firebase_request_dto_validation_error.dart';

class FirebaseSigninUser
    implements FirebaseAuthRequest<UserCredential, FirebaseSigninDto> {
  @override
  Future<UserCredential> execute(FirebaseSigninDto dto) async {
    if (!dto.validate()) {
      throw FirebaseRequestDtoValidationError(dto.validationErrors);
    }

    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: dto.email,
        password: dto.password,
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthError(e);
    }
  }
}
