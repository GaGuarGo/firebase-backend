import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

class AvatarUpload extends FirebaseUploadToStorage {
  @override
  String get path => 'profile_pictures';
}

/// Fails every upload, so the FirebaseException mapping can be exercised.
///
/// MockFirebaseStorage always succeeds, so a hand written double is the only
/// way to reach the error branch.
class ThrowingReference implements Reference {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw FirebaseException(
    plugin: 'firebase_storage',
    code: 'unauthorized',
    message: 'User is not authorized to perform the desired action.',
  );
}

class ThrowingStorage implements FirebaseStorage {
  @override
  Reference ref([String? path]) => ThrowingReference();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FailingUpload extends FirebaseUploadToStorage {
  @override
  String get path => 'profile_pictures';

  @override
  FirebaseStorage get storage => ThrowingStorage();
}

void main() {
  late MockFirebaseStorage storage;
  late AvatarUpload uploader;
  late Directory tempDir;

  setUp(() {
    storage = MockFirebaseStorage();
    FirebaseBackend.storage = storage;
    uploader = AvatarUpload();
    tempDir = Directory.systemTemp.createTempSync('firebase_backend_test');
  });

  tearDown(() {
    FirebaseBackend.reset();
    tempDir.deleteSync(recursive: true);
  });

  File writeFile(String name) =>
      File('${tempDir.path}${Platform.pathSeparator}$name')
        ..writeAsStringSync('conteúdo');

  test('uploads the file and returns a download URL', () async {
    final url = await uploader.upload(file: writeFile('avatar.png'));

    expect(url, contains('profile_pictures'));
    expect(url, contains('avatar.png'));
  });

  /// The single object path the mock recorded.
  ///
  /// Asserted with `contains` rather than an exact match because
  /// MockReference.child concatenates segments without a separator, which is a
  /// quirk of the mock, not of the code under test.
  String storedPath() => storage.storedDataMap.keys.single;

  test('defaults the object name to the file name', () async {
    await uploader.upload(file: writeFile('avatar.png'));

    expect(storedPath(), contains('profile_pictures'));
    expect(storedPath(), contains('avatar.png'));
  });

  test('an explicit fileName wins over the file name', () async {
    await uploader.upload(file: writeFile('avatar.png'), fileName: 'foto.png');

    expect(storedPath(), contains('foto.png'));
    expect(storedPath(), isNot(contains('avatar.png')));
  });

  test('referenceBuilder takes over placement', () async {
    await uploader.upload(
      file: writeFile('avatar.png'),
      referenceBuilder: (ref) => ref.child('uid-1').child('avatar.png'),
    );

    expect(storedPath(), contains('uid-1'));
    expect(storedPath(), contains('avatar.png'));
  });

  test('referenceBuilder wins over an explicit fileName', () async {
    await uploader.upload(
      file: writeFile('avatar.png'),
      fileName: 'ignorado.png',
      referenceBuilder: (ref) => ref.child('escolhido.png'),
    );

    expect(storedPath(), contains('escolhido.png'));
    expect(storedPath(), isNot(contains('ignorado.png')));
  });

  group('failures', () {
    test(
      'a FirebaseException becomes FirebaseBackendStorageException',
      () async {
        await expectLater(
          FailingUpload().upload(file: writeFile('avatar.png')),
          throwsA(
            isA<FirebaseBackendStorageException>()
                .having((e) => e.code, 'code', 'unauthorized')
                .having(
                  (e) => e.message,
                  'message',
                  contains('profile_pictures'),
                ),
          ),
        );
      },
    );

    test('the storage exception is a FirebaseBackendException', () async {
      await expectLater(
        FailingUpload().upload(file: writeFile('avatar.png')),
        throwsA(isA<FirebaseBackendException>()),
      );
    });
  });

  // Not covered: the kIsWeb branch (putBlob, and the timestamp based default
  // name). Both need a browser, so they are exercised only in a web build.
}
