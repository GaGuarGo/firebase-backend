import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_backend/src/domain/error/firebase_storage_error.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class FirebaseUploadToStorage {
  String get path;

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
