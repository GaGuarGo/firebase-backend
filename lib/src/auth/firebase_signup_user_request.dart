import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_backend/src/auth/dtos/firebase_signup_dto.dart';
import 'package:firebase_backend/src/auth/firebase_auth_request.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_auth_exception.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_validation_exception.dart';
import 'package:firebase_backend/src/domain/validation/dto_validation_error.dart';
import 'package:firebase_backend/src/firebase_backend_config.dart';
import 'package:flutter/foundation.dart' show protected;

/// Creates an email and password account.
class FirebaseSignupUserRequest
    implements FirebaseAuthRequest<UserCredential, FirebaseSignupDto> {
  /// Creates the request.
  ///
  /// [enforcePasswordPolicy] checks the password against the project's
  /// password policy before creating the account. That costs an extra network
  /// round trip to fetch the policy, so set it to `false` if you validate
  /// strength yourself.
  FirebaseSignupUserRequest({this.enforcePasswordPolicy = true});

  /// Whether to check the password against the project's password policy.
  final bool enforcePasswordPolicy;

  /// The Auth instance to register against. Defaults to [FirebaseBackend.auth].
  @protected
  FirebaseAuth get auth => FirebaseBackend.auth;

  /// Whether [password] satisfies the project's password policy.
  ///
  /// Fetches the policy from Firebase on every call. Override to apply your
  /// own rules without the round trip.
  @protected
  Future<bool> isPasswordStrong(String password) async =>
      (await auth.validatePassword(auth, password)).isValid;

  /// Creates the account described by [dto].
  ///
  /// When [FirebaseSignupDto.displayName] is set, it is applied to the new
  /// account and the user is reloaded so the returned credential carries it.
  ///
  /// Throws [FirebaseBackendValidationException] when the DTO is invalid or the
  /// password is rejected by the policy, and [FirebaseBackendAuthException]
  /// when Firebase rejects the registration.
  @override
  Future<UserCredential> execute(FirebaseSignupDto dto) async {
    if (!dto.validate()) {
      throw FirebaseBackendValidationException(dto.validationErrors);
    }

    if (enforcePasswordPolicy && !await isPasswordStrong(dto.password)) {
      throw FirebaseBackendValidationException(const [
        DtoValidationError(
          field: 'password',
          validationError: 'Senha não atende aos requisitos de segurança.',
        ),
      ]);
    }

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: dto.email,
        password: dto.password,
      );

      final displayName = dto.displayName;
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
        await credential.user?.reload();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseBackendAuthException(e);
    }
  }
}
