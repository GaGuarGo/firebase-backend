import 'package:firebase_backend/src/domain/exception/firebase_backend_storage_exception.dart';
import 'package:firebase_backend/src/firebase_backend_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb, protected;

/// Uploads files to the Storage folder at [path].
abstract class FirebaseUploadToStorage {
  /// The Firebase Storage folder this uploader writes into, for example
  /// `'profile_pictures'`.
  String get path;

  /// The Storage instance to upload to. Defaults to [FirebaseBackend.storage].
  @protected
  FirebaseStorage get storage => FirebaseBackend.storage;

  /// Uploads [file] and returns its download URL.
  ///
  /// [file] is platform dependent: a `dart:html` `Blob` on web, a `dart:io`
  /// `File` everywhere else. It is `dynamic` because those two types cannot
  /// both be imported in a single library.
  ///
  /// [fileName] names the object inside [path]. Without it the name comes from
  /// the file itself on native, and from the current timestamp on web, where
  /// a `Blob` carries no name.
  ///
  /// [referenceBuilder] takes over placement entirely when the default naming
  /// is not enough:
  ///
  /// ```dart
  /// await uploader.upload(
  ///   file: file,
  ///   referenceBuilder: (ref) => ref.child(userId).child('avatar.png'),
  /// );
  /// ```
  ///
  /// Throws [FirebaseBackendStorageException] when the upload fails.
  Future<String> upload({
    required dynamic file,
    String? fileName,
    Reference Function(Reference ref)? referenceBuilder,
  }) async {
    try {
      final baseRef = storage.ref(path);
      final ref = referenceBuilder != null
          ? referenceBuilder(baseRef)
          : baseRef.child(fileName ?? _defaultFileName(file));

      final uploadTask = kIsWeb
          ? await ref.putBlob(file)
          : await ref.putFile(file);

      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw FirebaseBackendStorageException(
        'Failed to upload file to $path: ${e.message ?? e.code}',
        code: e.code,
      );
    }
  }

  String _defaultFileName(dynamic file) {
    if (kIsWeb) return DateTime.now().millisecondsSinceEpoch.toString();
    return (file.uri as Uri).pathSegments.last;
  }
}
