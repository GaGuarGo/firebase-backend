import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_backend/src/firebase_backend_config.dart';
import 'package:flutter/foundation.dart';

/// Called when the authentication state changes.
typedef FirebaseAuthCallback = void Function();

/// Watches Firebase Auth and notifies listeners whenever the session changes.
///
/// ```dart
/// final listener = FirebaseAuthListener(
///   auth: () => goToHome(),
///   unauth: () => goToLogin(),
/// )..start();
///
/// // later
/// listener.dispose();
/// ```
class FirebaseAuthListener extends ChangeNotifier {
  /// Creates a listener that calls [auth] when a user signs in and [unauth]
  /// when they sign out.
  FirebaseAuthListener({required this.auth, this.unauth});

  /// Called whenever a user is signed in.
  final FirebaseAuthCallback auth;

  /// Called whenever no user is signed in.
  final FirebaseAuthCallback? unauth;

  StreamSubscription<User?>? _subscription;

  /// The Auth instance to watch. Defaults to [FirebaseBackend.auth].
  @protected
  FirebaseAuth get firebaseAuth => FirebaseBackend.auth;

  /// Whether this listener is currently subscribed.
  bool get isListening => _subscription != null;

  /// Subscribes to `authStateChanges`.
  ///
  /// Calling this again replaces the previous subscription rather than leaking
  /// it, so it is safe to call from a rebuild.
  void start() {
    stop();
    _subscription = firebaseAuth.authStateChanges().listen(
      (user) {
        if (user != null) {
          auth();
        } else {
          unauth?.call();
        }
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        log(
          'Error in auth state changes',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  /// Cancels the subscription, if any. Safe to call when not listening.
  void stop() {
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) unawaited(subscription.cancel());
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
