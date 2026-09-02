import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(FirebaseBackend.reset);

  test('resolves a known code to its default message', () {
    expect(firebaseAuthErrorMessage('weak-password'), 'A senha é muito fraca.');
  });

  test('an unknown code falls back to a message naming the code', () {
    final message = firebaseAuthErrorMessage('algo-inesperado');

    expect(message, contains('algo-inesperado'));
  });

  group('overrides', () {
    test('an override wins over the default', () {
      FirebaseBackend.authErrorMessages = {
        'weak-password': 'Password is weak.',
      };

      expect(firebaseAuthErrorMessage('weak-password'), 'Password is weak.');
    });

    test('codes absent from the override keep their default', () {
      FirebaseBackend.authErrorMessages = {
        'weak-password': 'Password is weak.',
      };

      expect(
        firebaseAuthErrorMessage('user-not-found'),
        'Usuário não encontrado.',
      );
    });

    test('an override can cover a code with no default', () {
      FirebaseBackend.authErrorMessages = {'quota-exceeded': 'Cota excedida.'};

      expect(firebaseAuthErrorMessage('quota-exceeded'), 'Cota excedida.');
    });

    test('reset restores the defaults', () {
      FirebaseBackend.authErrorMessages = {
        'weak-password': 'Password is weak.',
      };
      FirebaseBackend.reset();

      expect(
        firebaseAuthErrorMessage('weak-password'),
        'A senha é muito fraca.',
      );
    });
  });

  test('every default message is non-empty', () {
    for (final entry in kDefaultFirebaseAuthErrorMessages.entries) {
      expect(entry.value, isNotEmpty, reason: 'código ${entry.key}');
    }
  });
}
