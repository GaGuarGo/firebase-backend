import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_doubles.dart';

class Boom implements Exception {}

/// Marks both notes as done, reading them both before writing either.
class MarkPairDone extends FirebaseTransactionEndpoint<NoteDto, int> {
  MarkPairDone(this.first, this.second);

  final String first;
  final String second;

  /// How many times the body ran, so tests can assert on retries.
  int runs = 0;

  @override
  String get path => notesPath;

  @override
  Future<int> execute(FirebaseTransactionContext ctx, NoteDto dto) async {
    runs++;

    final a = await ctx.get(doc(first));
    final b = await ctx.get(doc(second));

    ctx.updateRaw(a.reference, {'done': true});
    ctx.updateRaw(b.reference, {'done': true});

    return 2;
  }
}

/// Writes the first note, then throws, so exception propagation is observable.
class WriteThenFail extends FirebaseTransactionEndpoint<NoteDto, void> {
  @override
  String get path => notesPath;

  @override
  Future<void> execute(FirebaseTransactionContext ctx, NoteDto dto) async {
    ctx.updateRaw(doc('n1'), {'title': 'não deveria persistir'});
    throw Boom();
  }
}

/// Fails the way Firestore itself would, so the error mapping in `run` is
/// exercised.
class FailWithFirebaseException
    extends FirebaseTransactionEndpoint<NoteDto, void> {
  @override
  String get path => notesPath;

  @override
  Future<void> execute(FirebaseTransactionContext ctx, NoteDto dto) async {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'aborted',
      message: 'too much contention',
    );
  }
}

/// Reads after writing, which Firestore forbids.
class ReadAfterWrite extends FirebaseTransactionEndpoint<NoteDto, void> {
  @override
  String get path => notesPath;

  @override
  Future<void> execute(FirebaseTransactionContext ctx, NoteDto dto) async {
    ctx.updateRaw(doc('n1'), {'done': true});
    await ctx.get(doc('n2'));
  }
}

/// Writes the DTO it was handed, so validation inside the body is observable.
class WriteDto extends FirebaseTransactionEndpoint<NoteDto, void> {
  WriteDto(this.payload);

  final NoteDto payload;

  @override
  String get path => notesPath;

  @override
  Future<void> execute(FirebaseTransactionContext ctx, NoteDto dto) async {
    ctx.set(doc('n1'), payload);
  }
}

void main() {
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirebaseBackend.firestore = db;
  });

  tearDown(FirebaseBackend.reset);

  group('run', () {
    test('commits every write and returns the body result', () async {
      await seedNote(db, 'n1');
      await seedNote(db, 'n2');

      final result = await MarkPairDone('n1', 'n2').run(NoteDto());

      expect(result, 2);
      expect((await readNote(db, 'n1'))!['done'], isTrue);
      expect((await readNote(db, 'n2'))!['done'], isTrue);
    });

    test('runs the body exactly once when uncontended', () async {
      await seedNote(db, 'n1');
      await seedNote(db, 'n2');

      final endpoint = MarkPairDone('n1', 'n2');
      await endpoint.run(NoteDto());

      expect(endpoint.runs, 1);
    });

    // Note: rollback itself is NOT covered here. fake_cloud_firestore backs
    // runTransaction with a _DummyTransaction that applies every write
    // immediately, with no buffering and no rollback, so a fake-based test
    // cannot distinguish an atomic commit from an eager one. What this suite
    // does cover is everything this package adds on top: validation, the
    // read-before-write guard, and error mapping. Atomicity is Firestore's own
    // guarantee, exercised against a real project or the emulator.
    test('propagates an exception from the body unchanged', () async {
      await seedNote(db, 'n1', title: 'original');

      await expectLater(WriteThenFail().run(NoteDto()), throwsA(isA<Boom>()));
    });

    test(
      'maps a FirebaseException from the body to a transaction exception',
      () async {
        await expectLater(
          FailWithFirebaseException().run(NoteDto()),
          throwsA(
            isA<FirebaseBackendTransactionException>()
                .having((e) => e.code, 'code', 'aborted')
                .having((e) => e.message, 'message', contains(notesPath)),
          ),
        );
      },
    );

    test('a missing document aborts with the not found exception', () async {
      await seedNote(db, 'n1');

      await expectLater(
        MarkPairDone('n1', 'ausente').run(NoteDto()),
        throwsA(isA<FirebaseBackendNotFoundException>()),
      );

      expect((await readNote(db, 'n1'))!['done'], isFalse);
    });

    test('validates the DTO before opening a transaction', () async {
      await expectLater(
        MarkPairDone('n1', 'n2').run(NoteDto(title: '', author: '')),
        throwsA(
          isA<FirebaseBackendValidationException>().having(
            (e) => e.errors,
            'errors',
            hasLength(2),
          ),
        ),
      );
    });

    test('does not run the body when the DTO is invalid', () async {
      final endpoint = MarkPairDone('n1', 'n2');

      await expectLater(
        endpoint.run(NoteDto(title: '')),
        throwsA(isA<FirebaseBackendValidationException>()),
      );

      expect(endpoint.runs, 0);
    });
  });

  group('read-before-write', () {
    test('reading after a write fails fast with a clear exception', () async {
      await seedNote(db, 'n1');
      await seedNote(db, 'n2');

      await expectLater(
        ReadAfterWrite().run(NoteDto()),
        throwsA(
          isA<FirebaseBackendTransactionException>()
              .having((e) => e.code, 'code', 'read-after-write')
              .having((e) => e.message, 'message', contains('leituras')),
        ),
      );
    });

    test('the guard fires before Firestore reports it itself', () async {
      await seedNote(db, 'n1');
      await seedNote(db, 'n2');

      // Firestore raises an opaque PlatformException for this. The point of the
      // context is to catch it first and name it, so nothing platform specific
      // should reach the caller.
      await expectLater(
        ReadAfterWrite().run(NoteDto()),
        throwsA(isNot(isA<PlatformException>())),
      );
    });
  });

  group('DTO writes inside the body', () {
    test('a valid DTO is written', () async {
      await WriteDto(NoteDto(title: 'dentro')).run(NoteDto());

      expect((await readNote(db, 'n1'))!['title'], 'dentro');
    });

    test('an invalid DTO aborts the transaction', () async {
      await expectLater(
        WriteDto(NoteDto(title: '')).run(NoteDto()),
        throwsA(isA<FirebaseBackendValidationException>()),
      );

      expect(await readNote(db, 'n1'), isNull);
    });

    test(
      'a DTO validated on every attempt does not accumulate duplicate errors',
      () async {
        // The body is what re-runs on contention, so the DTO it validates must
        // survive repeated validation with a stable error list.
        final payload = NoteDto(title: '', author: '');
        final endpoint = WriteDto(payload);

        for (var attempt = 0; attempt < 3; attempt++) {
          await expectLater(
            endpoint.run(NoteDto()),
            throwsA(isA<FirebaseBackendValidationException>()),
          );
        }

        expect(payload.validationErrors, hasLength(2));
      },
    );
  });

  group('endpoint integration', () {
    test('a get endpoint can read inside a transaction', () async {
      await seedNote(db, 'n1', title: 'lido na transaction');

      final getEndpoint = NoteGetEndpoint();
      String? title;

      await db.runTransaction((transaction) async {
        final note = await getEndpoint.findOne('n1', transaction: transaction);
        title = note.title;
      });

      expect(title, 'lido na transaction');
    });

    test(
      'post, update and delete endpoints write inside a transaction',
      () async {
        await seedNote(db, 'existente', title: 'antigo');
        await seedNote(db, 'condenado');

        await db.runTransaction((transaction) async {
          await NotePostEndpoint().post(
            NoteDto(title: 'criado'),
            documentId: 'novo',
            transaction: transaction,
          );
          await NoteUpdateEndpoint().update(
            'existente',
            NoteDto(title: 'atualizado'),
            transaction: transaction,
          );
          await NoteDeleteEndpoint().delete(
            'condenado',
            transaction: transaction,
          );
        });

        expect((await readNote(db, 'novo'))!['title'], 'criado');
        expect((await readNote(db, 'existente'))!['title'], 'atualizado');
        expect(await readNote(db, 'condenado'), isNull);
      },
    );
  });
}
