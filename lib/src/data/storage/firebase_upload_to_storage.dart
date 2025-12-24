import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_backend/src/domain/error/firebase_storage_error.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class FirebaseUploadToStorage {
  /// The Firestore collection path for the endpoint.
  /// [path] is used to specify the collection from which documents will be retrieved.
  /// For example, if your collection is named "users", the path would be "users".
  /// If your collection is nested, you can specify the full path like "users/{userId}/posts".
  String get path;


  /// Uploads a file to Firebase Storage.
  /// [file] is the file to be uploaded. It can be a Blob (for web) or a File (for mobile).
  /// [fileName] is an optional name for the file. If not provided, the original file name will be used.
  /// [referenceBuilder] is an optional function to customize the storage reference.
  /// Returns a Future that resolves to the download URL of the uploaded file.
  Future<String> upload({
    required dynamic file,
    String? fileName,
    Reference Function(Reference ref)? referenceBuilder,
  }) async {
    try {
      final baseRef = FirebaseStorage.instance.ref(path);
      final ref = referenceBuilder != null
          ? referenceBuilder(baseRef)
          : baseRef.child(
              fileName ??
                  (kIsWeb ? (fileName ?? 'file') : file.uri.pathSegments.last),
            );

      late TaskSnapshot uploadTask;

      if (kIsWeb) {
        uploadTask = await ref.putBlob(file);
      } else {
        uploadTask = await ref.putFile(file);
      }

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw FirebaseStorageError('Failed to upload file to $path: $e');
    }
  }
}
