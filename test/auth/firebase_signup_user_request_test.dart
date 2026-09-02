import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

/// Overrides the password policy check so tests never reach the network.
///
/// This seam is the only reason signup is unit testable at all: the real
/// implementation calls `FirebaseAuth.validatePassword`, which fetches the
/// project's policy over the network and is not covered by MockFirebaseAuth.
class TestSignup extends FirebaseSignupUserRequest {
  TestSignup({this.strong = true});

  final bool strong;

  /// How many times the policy check ran.
  int policyChecks = 0;

  @override
  Future<bool> isPasswordStrong(String password) async {
    policyChecks++;
    return strong;
  }
}

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    FirebaseBackend.auth = mockAuth;
  });

  tearDown(FirebaseBackend.reset);

  test('creates the account and returns the credential', () async {
    final credential = await TestSignup().execute(
      FirebaseSignupDto(email: 'ana@example.com', password: 'segredo123'),
    );

    expect(credential.user?.email, 'ana@example.com');
  });

  test('applies the displayName when given', () async {
    final credential = await TestSignup().execute(
      FirebaseSignupDto(
        email: 'ana@example.com',
        password: 'segredo123',
        displayName: 'Ana Silva',
      ),
    );

    expect(credential.user?.displayName, 'Ana Silva');
  });

  group('password policy', () {
    test('rejects a password the policy refuses', () async {
      final request = TestSignup(strong: false);

      await expectLater(
        request.execute(
          FirebaseSignupDto(email: 'ana@example.com', password: 'fraca'),
        ),
        throwsA(
          isA<FirebaseBackendValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'password',
          ),
        ),
      );

      expect(mockAuth.currentUser, isNull);
    });

    test('runs the check exactly once for a valid DTO', () async {
      final request = TestSignup();

      await request.execute(
        FirebaseSignupDto(email: 'ana@example.com', password: 'segredo123'),
      );

      expect(request.policyChecks, 1);
    });

    test('skips the check when the DTO is already invalid', () async {
      final request = TestSignup();

      await expectLater(
        request.execute(FirebaseSignupDto(email: '', password: 'segredo123')),
        throwsA(isA<FirebaseBackendValidationException>()),
      );

      expect(request.policyChecks, 0);
    });

    test(
      'enforcePasswordPolicy: false avoids the policy round trip entirely',
      () async {
        // The unmodified request is used here on purpose: with the policy
        // enabled it would call validatePassword and hit the network.
        final credential =
            await FirebaseSignupUserRequest(
              enforcePasswordPolicy: false,
            ).execute(
              FirebaseSignupDto(email: 'ana@example.com', password: 'qualquer'),
            );

        expect(credential.user, isNotNull);
      },
    );
  });

  group('validation', () {
    test('rejects a malformed email', () async {
      await expectLater(
        TestSignup().execute(
          FirebaseSignupDto(email: 'ana@', password: 'segredo123'),
        ),
        throwsA(isA<FirebaseBackendValidationException>()),
      );
    });

    test('rejects a displayName shorter than three characters', () async {
      await expectLater(
        TestSignup().execute(
          FirebaseSignupDto(
            email: 'ana@example.com',
            password: 'segredo123',
            displayName: 'An',
          ),
        ),
        throwsA(
          isA<FirebaseBackendValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'displayName',
          ),
        ),
      );
    });

    test('treats an empty displayName as absent', () async {
      await expectLater(
        TestSignup().execute(
          FirebaseSignupDto(
            email: 'ana@example.com',
            password: 'segredo123',
            displayName: '',
          ),
        ),
        completes,
      );
    });
  });

  test('maps FirebaseAuthException to the package exception', () async {
    whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
        .on(mockAuth)
        .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

    await expectLater(
      TestSignup().execute(
        FirebaseSignupDto(email: 'ana@example.com', password: 'segredo123'),
      ),
      throwsA(
        isA<FirebaseBackendAuthException>()
            .having((e) => e.code, 'code', 'email-already-in-use')
            .having((e) => e.message, 'message', 'Este e-mail já está em uso.'),
      ),
    );
  });
}
