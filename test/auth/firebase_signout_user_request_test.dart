import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FirebaseSignoutUserRequest request;

  setUp(() {
    mockAuth = MockFirebaseAuth(signedIn: true);
    FirebaseBackend.auth = mockAuth;
    request = FirebaseSignoutUserRequest();
  });

  tearDown(FirebaseBackend.reset);

  test('signs the current user out', () async {
    expect(mockAuth.currentUser, isNotNull);

    await request.execute();

    expect(mockAuth.currentUser, isNull);
  });

  test('takes no DTO', () async {
    // Regression guard: this used to implement the raw FirebaseAuthRequest,
    // forcing callers to pass a DTO that was never read.
    await expectLater(request.execute(), completes);
  });

  test('is a no-op when nobody is signed in', () async {
    FirebaseBackend.auth = MockFirebaseAuth();

    await expectLater(FirebaseSignoutUserRequest().execute(), completes);
  });

  test('maps FirebaseAuthException to the package exception', () async {
    whenCalling(Invocation.method(#signOut, [null]))
        .on(mockAuth)
        .thenThrow(FirebaseAuthException(code: 'network-request-failed'));

    await expectLater(
      request.execute(),
      throwsA(
        isA<FirebaseBackendAuthException>().having(
          (e) => e.message,
          'message',
          'Falha de rede. Verifique sua conexão.',
        ),
      ),
    );
  });
}
