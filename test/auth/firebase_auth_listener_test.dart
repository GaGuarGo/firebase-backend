import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    FirebaseBackend.auth = mockAuth;
  });

  tearDown(FirebaseBackend.reset);

  /// Records which callback fired, in order, so the initial emission is
  /// visible instead of being folded into a count.
  List<String> trackedCalls(FirebaseAuthListener Function(List<String>) build) {
    final calls = <String>[];
    build(calls).start();
    return calls;
  }

  FirebaseAuthListener tracking(List<String> calls) => FirebaseAuthListener(
    auth: () => calls.add('auth'),
    unauth: () => calls.add('unauth'),
  );

  // authStateChanges emits the current state as soon as you subscribe, so a
  // listener started while signed out gets an immediate 'unauth'. This mirrors
  // real Firebase and is what makes the listener usable to drive a splash
  // screen.
  test('reports the current state immediately on start', () async {
    final calls = trackedCalls(tracking);
    await pumpEventQueue();

    expect(calls, ['unauth']);
  });

  test('calls the auth callback when a user signs in', () async {
    final calls = trackedCalls(tracking);

    await mockAuth.signInWithEmailAndPassword(
      email: 'ana@example.com',
      password: 'segredo123',
    );
    await pumpEventQueue();

    expect(calls, ['unauth', 'auth']);
  });

  test('calls the unauth callback when the user signs out', () async {
    final calls = trackedCalls(tracking);

    await mockAuth.signInWithEmailAndPassword(
      email: 'ana@example.com',
      password: 'segredo123',
    );
    await mockAuth.signOut();
    await pumpEventQueue();

    expect(calls, ['unauth', 'auth', 'unauth']);
  });

  test('notifies its listeners on every change', () async {
    var notifications = 0;
    FirebaseAuthListener(auth: () {})
      ..addListener(() => notifications++)
      ..start();

    await mockAuth.signInWithEmailAndPassword(
      email: 'ana@example.com',
      password: 'segredo123',
    );
    await pumpEventQueue();

    // The initial state plus the sign-in.
    expect(notifications, 2);
  });

  test('works without an unauth callback', () async {
    FirebaseAuthListener(auth: () {}).start();

    await mockAuth.signInWithEmailAndPassword(
      email: 'ana@example.com',
      password: 'segredo123',
    );
    await expectLater(mockAuth.signOut(), completes);
  });

  group('lifecycle', () {
    // Regression test: the subscription used to be a `late` non-nullable field,
    // so disposing before starting threw LateInitializationError.
    test('dispose before start does not throw', () {
      expect(FirebaseAuthListener(auth: () {}).dispose, returnsNormally);
    });

    test('stop before start does not throw', () {
      expect(FirebaseAuthListener(auth: () {}).stop, returnsNormally);
    });

    test('isListening tracks the subscription', () {
      final listener = FirebaseAuthListener(auth: () {});

      expect(listener.isListening, isFalse);
      listener.start();
      expect(listener.isListening, isTrue);
      listener.stop();
      expect(listener.isListening, isFalse);
    });

    // Regression test: calling start twice used to leak the first
    // subscription, so every event fired the callbacks twice.
    test('starting twice does not double up the callbacks', () async {
      var calls = 0;
      FirebaseAuthListener(auth: () => calls++)
        ..start()
        ..start();

      await mockAuth.signInWithEmailAndPassword(
        email: 'ana@example.com',
        password: 'segredo123',
      );
      await pumpEventQueue();

      // One sign-in event, one callback: the first subscription was cancelled
      // rather than left running alongside the second.
      expect(calls, 1);
    });

    test('a stopped listener receives nothing', () async {
      var calls = 0;
      FirebaseAuthListener(auth: () => calls++)
        ..start()
        ..stop();

      await mockAuth.signInWithEmailAndPassword(
        email: 'ana@example.com',
        password: 'segredo123',
      );
      await pumpEventQueue();

      expect(calls, 0);
    });
  });
}
