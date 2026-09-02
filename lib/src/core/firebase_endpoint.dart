import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_backend/src/firebase_backend_config.dart';
import 'package:flutter/foundation.dart' show protected;

/// Shared plumbing for every Firestore endpoint in this package.
///
/// It is a mixin rather than a base class so that a single class can combine
/// several endpoints for the same collection:
///
/// ```dart
/// class UserRepository extends FirebaseGetEndpoint<UserResponseDto> {
///   @override
///   String get path => 'users';
/// }
/// ```
mixin FirebaseEndpoint {
  /// The Firestore collection path this endpoint operates on.
  ///
  /// For a top level collection this is just its name (`'users'`). Nested
  /// collections use the full path with an odd number of segments
  /// (`'users/{userId}/posts'`).
  String get path;

  /// The Firestore instance backing this endpoint.
  ///
  /// Defaults to [FirebaseBackend.firestore]. Override it to point a single
  /// endpoint at a different Firebase app.
  @protected
  FirebaseFirestore get firestore => FirebaseBackend.firestore;

  /// The collection at [path].
  @protected
  CollectionReference<Map<String, dynamic>> get collection =>
      firestore.collection(path);

  /// The document [documentId] inside [collection].
  @protected
  DocumentReference<Map<String, dynamic>> doc(String documentId) =>
      collection.doc(documentId);
}
