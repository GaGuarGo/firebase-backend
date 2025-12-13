// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_backend/src/handlers/firebase_auth_code_error_handler.dart';

class FirebaseAuthError implements Exception {
  FirebaseAuthException firebaseAuthException;

  FirebaseAuthError(this.firebaseAuthException);

  @override
  String toString() => firebaseAuthErrorMessage(firebaseAuthException.code);
}
