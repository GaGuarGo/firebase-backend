import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_doubles.dart';

void main() {
  late FakeFirebaseFirestore db;
  late NotePostEndpoint endpoint;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirebaseBackend.firestore = db;
    endpoint = NotePostEndpoint();
  });

  tearDown(FirebaseBackend.reset);

  test('writes the document and returns the built response', () async {
    final response = await endpoint.post(NoteDto(title: 'estudar'));

    expect(response.title, 'estudar');
    expect(await readNote(db, response.id), {
      'title': 'estudar',
      'done': false,
      'author': 'ana',
    });
  });

  test('generates an id when none is given', () async {
    final first = await endpoint.post(NoteDto());
    final second = await endpoint.post(NoteDto());

    expect(first.id, isNotEmpty);
    expect(first.id, isNot(second.id));
    expect((await db.collection(notesPath).get()).docs, hasLength(2));
  });

  test('honours an explicit documentId', () async {
    final response = await endpoint.post(NoteDto(), documentId: 'uid-123');

    expect(response.id, 'uid-123');
    expect(await readNote(db, 'uid-123'), isNotNull);
  });

  test('an explicit documentId overwrites the existing document', () async {
    await seedNote(db, 'uid-123', title: 'antigo');

    await endpoint.post(NoteDto(title: 'novo'), documentId: 'uid-123');

    expect((await readNote(db, 'uid-123'))!['title'], 'novo');
  });

  group('validation', () {
    test('rejects an invalid DTO', () async {
      await expectLater(
        endpoint.post(NoteDto(title: '')),
        throwsA(
          isA<FirebaseBackendValidationException>().having(
            (e) => e.errors.map((error) => error.field),
            'fields',
            ['title'],
          ),
        ),
      );
    });

    test('writes nothing when the DTO is invalid', () async {
      await expectLater(
        endpoint.post(NoteDto(title: ''), documentId: 'n1'),
        throwsA(isA<FirebaseBackendValidationException>()),
      );

      expect((await db.collection(notesPath).get()).docs, isEmpty);
    });
  });
}
