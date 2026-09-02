import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FirebaseSigninUser request;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    FirebaseBackend.auth = mockAuth;
    request = FirebaseSigninUser();
  });

  tearDown(FirebaseBackend.reset);

  test('signs in and returns the credential', () async {
    final credential = await request.execute(
      FirebaseSigninDto(email: 'ana@example.com', password: 'segredo123'),
    );

    expect(credential.user, isNotNull);
    expect(mockAuth.currentUser, isNotNull);
  });

  group('validation', () {
    test('rejects an empty email before reaching Firebase', () async {
      await expectLater(
        request.execute(FirebaseSigninDto(email: '', password: 'segredo123')),
        throwsA(
          isA<FirebaseBackendValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'email',
          ),
        ),
      );

      expect(mockAuth.currentUser, isNull);
    });

    test('rejects a malformed email', () async {
      await expectLater(
        request.execute(
          FirebaseSigninDto(email: 'ana@', password: 'segredo123'),
        ),
        throwsA(isA<FirebaseBackendValidationException>()),
      );
    });

    test('reports both fields when both are empty', () async {
      await expectLater(
        request.execute(FirebaseSigninDto(email: '', password: '')),
        throwsA(
          isA<FirebaseBackendValidationException>().having(
            (e) => e.errors.map((error) => error.field),
            'fields',
            ['email', 'password'],
          ),
        ),
      );
    });
  });

  group('Firebase failures', () {
    test('maps FirebaseAuthException to the package exception', () async {
      whenCalling(
        Invocation.method(#signInWithEmailAndPassword, null),
      ).on(mockAuth).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      await expectLater(
        request.execute(
          FirebaseSigninDto(email: 'ana@example.com', password: 'errada'),
        ),
        throwsA(
          isA<FirebaseBackendAuthException>()
              .having((e) => e.code, 'code', 'wrong-password')
              .having((e) => e.message, 'message', 'Senha incorreta.'),
        ),
      );
    });

    test('an unknown code still produces a readable message', () async {
      whenCalling(
        Invocation.method(#signInWithEmailAndPassword, null),
      ).on(mockAuth).thenThrow(FirebaseAuthException(code: 'quota-exceeded'));

      await expectLater(
        request.execute(
          FirebaseSigninDto(email: 'ana@example.com', password: 'segredo123'),
        ),
        throwsA(
          isA<FirebaseBackendAuthException>().having(
            (e) => e.message,
            'message',
            contains('quota-exceeded'),
          ),
        ),
      );
    });

    test('the auth exception is a FirebaseBackendException', () async {
      whenCalling(
        Invocation.method(#signInWithEmailAndPassword, null),
      ).on(mockAuth).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await expectLater(
        request.execute(
          FirebaseSigninDto(email: 'ana@example.com', password: 'segredo123'),
        ),
        throwsA(isA<FirebaseBackendException>()),
      );
    });
  });
}
