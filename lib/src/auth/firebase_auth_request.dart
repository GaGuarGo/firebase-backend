import 'package:firebase_backend/src/domain/validation/validatable.dart';

/// A single Firebase Auth operation driven by a validated [D].
///
/// Implement this to add auth operations beyond the ones this package ships,
/// keeping the same shape: validate first, then map [FirebaseAuthException] to
/// [FirebaseBackendAuthException].
abstract class FirebaseAuthRequest<T, D extends Validatable> {
  /// Runs the operation described by [dto].
  Future<T> execute(D dto);
}
