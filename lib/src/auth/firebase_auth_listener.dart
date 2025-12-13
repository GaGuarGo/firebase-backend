import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthListener extends ChangeNotifier {
  final FirebaseAuthCallback auth;
  final FirebaseAuthCallback? unauth;

  FirebaseAuthListener({required this.auth, this.unauth});

  late StreamSubscription<User?> userAuthSubscription;

  Future<void> authListener() {
    userAuthSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        if (user != null) {
          auth();
        } else {
          if (unauth != null) {
            unauth!();
          }
        }
        notifyListeners();
      },
      onError: (error) {
        log('Error in auth state changes', error: error);
      },
    );
    return Future.value();
  }

  @override
  Future<void> dispose() async {
    await userAuthSubscription.cancel();
    super.dispose();
  }
}

typedef FirebaseAuthCallback = void Function();
