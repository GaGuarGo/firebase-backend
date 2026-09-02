import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_doubles.dart';

void main() {
  late FakeFirebaseFirestore db;
  late NoteGetEndpoint endpoint;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirebaseBackend.firestore = db;
    endpoint = NoteGetEndpoint();
  });

  tearDown(FirebaseBackend.reset);

  group('findOne', () {
    test('returns the response DTO built from the document', () async {
      await seedNote(db, 'n1', title: 'comprar pão', done: true);

      final note = await endpoint.findOne('n1');

      expect(note.id, 'n1');
      expect(note.title, 'comprar pão');
      expect(note.done, isTrue);
    });

    test('throws a not found exception for a missing document', () async {
      await expectLater(
        endpoint.findOne('ausente'),
        throwsA(
          isA<FirebaseBackendNotFoundException>()
              .having((e) => e.documentId, 'documentId', 'ausente')
              .having((e) => e.path, 'path', notesPath),
        ),
      );
    });

    test('the not found exception is a FirebaseBackendException', () async {
      await expectLater(
        endpoint.findOne('ausente'),
        throwsA(isA<FirebaseBackendException>()),
      );
    });
  });

  group('findAll', () {
    test('returns every document in the collection', () async {
      await seedNote(db, 'n1');
      await seedNote(db, 'n2');

      final notes = await endpoint.findAll();

      expect(notes.map((n) => n.id), unorderedEquals(['n1', 'n2']));
    });

    test('returns an empty list for an empty collection', () async {
      expect(await endpoint.findAll(), isEmpty);
    });

    test('applies the queryBuilder', () async {
      await seedNote(db, 'n1', done: true);
      await seedNote(db, 'n2');
      await seedNote(db, 'n3', done: true);

      final notes = await endpoint.findAll(
        queryBuilder: (query) => query.where('done', isEqualTo: true),
      );

      expect(notes.map((n) => n.id), unorderedEquals(['n1', 'n3']));
    });
  });

  group('dependency injection', () {
    test('an endpoint can override firestore independently', () async {
      final other = FakeFirebaseFirestore();
      await other.collection(notesPath).doc('only-here').set({'title': 'x'});

      // The global still points at `db`, which has no such document.
      await expectLater(
        endpoint.findOne('only-here'),
        throwsA(isA<FirebaseBackendNotFoundException>()),
      );

      FirebaseBackend.firestore = other;
      expect((await NoteGetEndpoint().findOne('only-here')).title, 'x');
    });
  });
}
