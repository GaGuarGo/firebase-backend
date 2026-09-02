import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_backend/src/domain/exception/firebase_backend_auth_exception.dart';
import 'package:firebase_backend/src/firebase_backend_config.dart';
import 'package:flutter/foundation.dart' show protected;

/// Signs the current user out.
///
/// This takes no DTO, so it does not implement [FirebaseAuthRequest].
class FirebaseSignoutUserRequest {
  /// The Auth instance to sign out of. Defaults to [FirebaseBackend.auth].
  @protected
  FirebaseAuth get auth => FirebaseBackend.auth;

  /// Signs out, ending the current session.
  ///
  /// Throws [FirebaseBackendAuthException] if Firebase rejects the sign-out.
  Future<void> execute() async {
    try {
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw FirebaseBackendAuthException(e);
    }
  }
}
