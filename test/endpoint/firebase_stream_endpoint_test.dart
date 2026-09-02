import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_doubles.dart';

/// Fails while converting a snapshot, so the failure reaches the stream the
/// same way a Firestore listener failure does: through the error channel,
/// never by throwing from the call that created the stream.
class ExplodingStreamEndpoint extends FirebaseStreamEndpoint<NoteResponseDto> {
  @override
  String get path => notesPath;

  @override
  NoteResponseDto buildResponse(DocumentSnapshot<Map<String, dynamic>> doc) =>
      throw StateError('boom');
}

void main() {
  late FakeFirebaseFirestore db;
  late NoteStreamEndpoint endpoint;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirebaseBackend.firestore = db;
    endpoint = NoteStreamEndpoint();
  });

  tearDown(FirebaseBackend.reset);

  group('streamAll', () {
    test('emits the current contents of the collection', () async {
      await seedNote(db, 'n1');

      await expectLater(
        endpoint.streamAll(),
        emits(
          isA<List<NoteResponseDto>>().having(
            (notes) => notes.single.id,
            'single id',
            'n1',
          ),
        ),
      );
    });

    test('emits again when the collection changes', () async {
      final expectation = expectLater(
        endpoint.streamAll().map((notes) => notes.length),
        emitsInOrder([0, 1, 2]),
      );

      await seedNote(db, 'n1');
      await seedNote(db, 'n2');

      await expectation;
    });

    test('applies the queryBuilder', () async {
      await seedNote(db, 'n1', done: true);
      await seedNote(db, 'n2');

      await expectLater(
        endpoint.streamAll(
          queryBuilder: (query) => query.where('done', isEqualTo: true),
        ),
        emits(
          isA<List<NoteResponseDto>>().having(
            (notes) => notes.single.id,
            'single id',
            'n1',
          ),
        ),
      );
    });
  });

  group('streamById', () {
    test('emits the document', () async {
      await seedNote(db, 'n1', title: 'ler');

      await expectLater(
        endpoint.streamById('n1'),
        emits(isA<NoteResponseDto>().having((n) => n.title, 'title', 'ler')),
      );
    });

    test('emits null while the document does not exist', () async {
      await expectLater(endpoint.streamById('ausente'), emits(isNull));
    });

    test('emits the document once it appears', () async {
      final expectation = expectLater(
        endpoint.streamById('n1').map((note) => note?.title),
        emitsInOrder([null, 'ler']),
      );

      await seedNote(db, 'n1', title: 'ler');

      await expectation;
    });
  });

  group('error handling', () {
    // Regression test: the previous implementation wrapped only the synchronous
    // construction of the stream in try/catch, which never fires. Failures
    // escaped unwrapped through the error channel.
    test(
      'streamAll reports failures as FirebaseBackendStreamException',
      () async {
        await seedNote(db, 'n1');

        await expectLater(
          ExplodingStreamEndpoint().streamAll(),
          emitsError(
            isA<FirebaseBackendStreamException>()
                .having((e) => e.message, 'message', contains(notesPath))
                .having((e) => e.cause, 'cause', isA<StateError>()),
          ),
        );
      },
    );

    test(
      'streamById reports failures as FirebaseBackendStreamException',
      () async {
        await seedNote(db, 'n1');

        await expectLater(
          ExplodingStreamEndpoint().streamById('n1'),
          emitsError(
            isA<FirebaseBackendStreamException>().having(
              (e) => e.message,
              'message',
              contains('n1'),
            ),
          ),
        );
      },
    );

    test('creating the stream never throws synchronously', () {
      expect(() => ExplodingStreamEndpoint().streamAll(), returnsNormally);
    });
  });
}
