import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_doubles.dart';

void main() {
  late FakeFirebaseFirestore db;
  late NoteUpdateEndpoint endpoint;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirebaseBackend.firestore = db;
    endpoint = NoteUpdateEndpoint();
  });

  tearDown(FirebaseBackend.reset);

  test('merges the DTO into the existing document', () async {
    await seedNote(db, 'n1', title: 'antigo');

    final response = await endpoint.update('n1', NoteDto(title: 'novo'));

    expect(response.title, 'novo');
    expect((await readNote(db, 'n1'))!['title'], 'novo');
  });

  test('a missing document fails with the package not found exception, '
      'not a raw FirebaseException', () async {
    await expectLater(
      endpoint.update('ausente', NoteDto()),
      throwsA(
        isA<FirebaseBackendNotFoundException>()
            .having((e) => e.documentId, 'documentId', 'ausente')
            .having((e) => e.path, 'path', notesPath),
      ),
    );
  });

  group('validation', () {
    test('rejects an invalid DTO', () async {
      await seedNote(db, 'n1');

      await expectLater(
        endpoint.update('n1', NoteDto(title: '', author: '')),
        throwsA(
          isA<FirebaseBackendValidationException>().having(
            (e) => e.errors,
            'errors',
            hasLength(2),
          ),
        ),
      );
    });

    test('leaves the document untouched when the DTO is invalid', () async {
      await seedNote(db, 'n1', title: 'antigo');

      await expectLater(
        endpoint.update('n1', NoteDto(title: '')),
        throwsA(isA<FirebaseBackendValidationException>()),
      );

      expect((await readNote(db, 'n1'))!['title'], 'antigo');
    });
  });
}
