import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_doubles.dart';

void main() {
  late FakeFirebaseFirestore db;
  late NoteDeleteEndpoint endpoint;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirebaseBackend.firestore = db;
    endpoint = NoteDeleteEndpoint();
  });

  tearDown(FirebaseBackend.reset);

  test('removes the document', () async {
    await seedNote(db, 'n1');

    await endpoint.delete('n1');

    expect(await readNote(db, 'n1'), isNull);
  });

  test('throws a not found exception for a missing document', () async {
    await expectLater(
      endpoint.delete('ausente'),
      throwsA(
        isA<FirebaseBackendNotFoundException>().having(
          (e) => e.documentId,
          'documentId',
          'ausente',
        ),
      ),
    );
  });

  test('ensureExists: false skips the existence read and stays silent on a '
      'missing document', () async {
    await expectLater(
      endpoint.delete('ausente', ensureExists: false),
      completes,
    );
  });

  test('ensureExists: false still deletes an existing document', () async {
    await seedNote(db, 'n1');

    await endpoint.delete('n1', ensureExists: false);

    expect(await readNote(db, 'n1'), isNull);
  });
}
