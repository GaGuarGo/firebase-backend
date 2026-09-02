import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_doubles.dart';

/// Runs [body] against a real transaction context so the class can be
/// exercised directly, without going through an endpoint.
Future<T> withContext<T>(
  FakeFirebaseFirestore db,
  Future<T> Function(FirebaseTransactionContext ctx) body,
) => db.runTransaction(
  (transaction) => body(FirebaseTransactionContext(db, transaction)),
);

void main() {
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirebaseBackend.firestore = db;
  });

  tearDown(FirebaseBackend.reset);

  group('get', () {
    test('returns the snapshot for an existing document', () async {
      await seedNote(db, 'n1', title: 'presente');

      final title = await withContext(db, (ctx) async {
        final snapshot = await ctx.get(ctx.doc(notesPath, 'n1'));
        return snapshot.data()!['title'] as String;
      });

      expect(title, 'presente');
    });

    test('throws for a missing document by default', () async {
      await expectLater(
        withContext(db, (ctx) => ctx.get(ctx.doc(notesPath, 'ausente'))),
        throwsA(isA<FirebaseBackendNotFoundException>()),
      );
    });

    test('required: false returns a non-existent snapshot instead', () async {
      final exists = await withContext(db, (ctx) async {
        final snapshot = await ctx.get(
          ctx.doc(notesPath, 'ausente'),
          required: false,
        );
        return snapshot.exists;
      });

      expect(exists, isFalse);
    });
  });

  group('hasWritten', () {
    test('is false before any write', () async {
      final written = await withContext(db, (ctx) async => ctx.hasWritten);

      expect(written, isFalse);
    });

    test('flips on the first write', () async {
      final written = await withContext(db, (ctx) async {
        ctx.setRaw(ctx.doc(notesPath, 'n1'), {'title': 'x'});
        return ctx.hasWritten;
      });

      expect(written, isTrue);
    });
  });

  group('writes', () {
    test('set creates a document from a DTO', () async {
      await withContext(
        db,
        (ctx) async => ctx.set(ctx.doc(notesPath, 'n1'), NoteDto(title: 'a')),
      );

      expect((await readNote(db, 'n1'))!['title'], 'a');
    });

    test('update merges a DTO into an existing document', () async {
      await seedNote(db, 'n1', title: 'antigo');

      await withContext(
        db,
        (ctx) async =>
            ctx.update(ctx.doc(notesPath, 'n1'), NoteDto(title: 'novo')),
      );

      expect((await readNote(db, 'n1'))!['title'], 'novo');
    });

    test('updateRaw supports field level operations', () async {
      await db.collection(notesPath).doc('n1').set({'views': 1});

      await withContext(
        db,
        (ctx) async => ctx.updateRaw(ctx.doc(notesPath, 'n1'), {
          'views': FieldValue.increment(2),
        }),
      );

      expect((await readNote(db, 'n1'))!['views'], 3);
    });

    test('delete removes the document', () async {
      await seedNote(db, 'n1');

      await withContext(
        db,
        (ctx) async => ctx.delete(ctx.doc(notesPath, 'n1')),
      );

      expect(await readNote(db, 'n1'), isNull);
    });

    test('set rejects an invalid DTO and writes nothing', () async {
      await expectLater(
        withContext(
          db,
          (ctx) async => ctx.set(ctx.doc(notesPath, 'n1'), NoteDto(title: '')),
        ),
        throwsA(isA<FirebaseBackendValidationException>()),
      );

      expect(await readNote(db, 'n1'), isNull);
    });
  });

  group('raw', () {
    test('exposes the underlying transaction', () async {
      final isTransaction = await withContext(
        db,
        (ctx) async => identical(ctx.raw, ctx.raw),
      );

      expect(isTransaction, isTrue);
    });
  });
}
