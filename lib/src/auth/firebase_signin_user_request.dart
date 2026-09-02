import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_backend/src/auth/dtos/firebase_signin_dto.dart';
import 'package:firebase_backend/src/auth/firebase_auth_request.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_auth_exception.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_validation_exception.dart';
import 'package:firebase_backend/src/firebase_backend_config.dart';
import 'package:flutter/foundation.dart' show protected;

/// Signs a user in with email and password.
class FirebaseSigninUser
    implements FirebaseAuthRequest<UserCredential, FirebaseSigninDto> {
  /// The Auth instance to sign in against. Defaults to [FirebaseBackend.auth].
  @protected
  FirebaseAuth get auth => FirebaseBackend.auth;

  /// Signs in with the credentials in [dto].
  ///
  /// Throws [FirebaseBackendValidationException] before reaching Firebase when
  /// the credentials are malformed, and [FirebaseBackendAuthException] when
  /// Firebase rejects them.
  @override
  Future<UserCredential> execute(FirebaseSigninDto dto) async {
    if (!dto.validate()) {
      throw FirebaseBackendValidationException(dto.validationErrors);
    }

    try {
      return await auth.signInWithEmailAndPassword(
        email: dto.email,
        password: dto.password,
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseBackendAuthException(e);
    }
  }
}
