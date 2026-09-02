import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

/// Holds the Firebase services every endpoint in this package talks to.
///
/// Each getter lazily falls back to the real singleton, so nothing touches
/// Firebase until it is actually used. Assign a fake before the first read to
/// unit test code built on this package:
///
/// ```dart
/// setUp(() => FirebaseBackend.firestore = FakeFirebaseFirestore());
/// tearDown(FirebaseBackend.reset);
/// ```
///
/// Individual endpoints can also override their own `firestore` getter when a
/// single instance is not enough (for example, two Firebase apps).
class FirebaseBackend {
  FirebaseBackend._();

  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static FirebaseStorage? _storage;
  static Map<String, String>? _authErrorMessages;

  /// The Firestore instance used by every endpoint.
  static FirebaseFirestore get firestore =>
      _firestore ??= FirebaseFirestore.instance;

  static set firestore(FirebaseFirestore value) => _firestore = value;

  /// The Auth instance used by every auth request.
  static FirebaseAuth get auth => _auth ??= FirebaseAuth.instance;

  static set auth(FirebaseAuth value) => _auth = value;

  /// The Storage instance used by [FirebaseUploadToStorage].
  static FirebaseStorage get storage => _storage ??= FirebaseStorage.instance;

  static set storage(FirebaseStorage value) => _storage = value;

  /// Overrides the user facing messages for Firebase Auth error codes.
  ///
  /// Codes absent from this map fall back to the built-in pt-BR defaults, so
  /// a partial map is enough to translate or reword only what you care about.
  static Map<String, String> get authErrorMessages =>
      _authErrorMessages ?? const {};

  static set authErrorMessages(Map<String, String> value) =>
      _authErrorMessages = value;

  /// Drops every override, restoring the real Firebase singletons.
  ///
  /// This only clears the references; it does not touch Firebase itself, so it
  /// is safe to call from a `tearDown` in an environment with no Firebase app.
  @visibleForTesting
  static void reset() {
    _firestore = null;
    _auth = null;
    _storage = null;
    _authErrorMessages = null;
  }
}
