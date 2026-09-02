import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('Validatable.validate', () {
    test('returns true and reports nothing for a valid object', () {
      final dto = NoteDto();

      expect(dto.validate(), isTrue);
      expect(dto.validationErrors, isEmpty);
    });

    test('reports every invalid field, not just the first', () {
      final dto = NoteDto(title: '', author: '');

      expect(dto.validate(), isFalse);
      expect(dto.validationErrors.map((e) => e.field), ['title', 'author']);
    });

    test('does not accumulate duplicates across repeated calls', () {
      final dto = NoteDto(title: '', author: '');

      dto.validate();
      dto.validate();
      dto.validate();

      expect(dto.validationErrors, hasLength(2));
    });

    test('clears stale errors once the object becomes valid', () {
      // Same instance cannot change here, so validate a bad one then a good one
      // and confirm the good one starts clean rather than inheriting state.
      final invalid = NoteDto(title: '');
      final valid = NoteDto();

      expect(invalid.validate(), isFalse);
      expect(valid.validate(), isTrue);
      expect(valid.validationErrors, isEmpty);
    });

    test('exposes an unmodifiable error list', () {
      final dto = NoteDto(title: '');
      dto.validate();

      expect(
        () => dto.validationErrors.add(
          const DtoValidationError(field: 'x', validationError: 'y'),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('FirebaseBackendValidationException', () {
    test('copies the errors so a re-validation cannot empty them', () {
      final dto = NoteDto(title: '', author: '');
      dto.validate();

      final exception = FirebaseBackendValidationException(
        dto.validationErrors,
      );

      dto.validate();

      expect(exception.errors, hasLength(2));
    });

    test('lists every offending field in its message', () {
      final dto = NoteDto(title: '', author: '');
      dto.validate();

      final message = FirebaseBackendValidationException(
        dto.validationErrors,
      ).toString();

      expect(message, contains('title'));
      expect(message, contains('author'));
    });
  });

  group('FirebaseNoRequestDto', () {
    test('is always valid and carries no payload', () {
      final dto = FirebaseNoRequestDto();

      expect(dto.validate(), isTrue);
      expect(dto.toJson(), isEmpty);
    });
  });

  group('isValidEmail', () {
    test('accepts ordinary addresses', () {
      expect(isValidEmail('ana@example.com'), isTrue);
      expect(isValidEmail('ana.silva-01@sub.example.com.br'), isTrue);
    });

    test('rejects malformed addresses', () {
      for (final invalid in ['', 'ana', 'ana@', '@example.com', 'ana@x.c']) {
        expect(isValidEmail(invalid), isFalse, reason: 'aceitou "$invalid"');
      }
    });
  });
}
