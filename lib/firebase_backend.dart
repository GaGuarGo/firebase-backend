import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


/// Initializes the Firebase backend with the provided options.
/// If [appCheck] is true, Firebase App Check is also initialized using
/// the provided [recaptchaSiteKey] for web platforms.
Future<void> intiFirebaseBackend({
  required FirebaseOptions options,
  bool appCheck = false,
  String recaptchaSiteKey = '',
}) async {
  assert(
    !appCheck && recaptchaSiteKey.isEmpty,
    'If appCheck is true, recaptchaSiteKey must be provided.',
  );

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: options); 

  if (appCheck) {
    if (kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        providerWeb: ReCaptchaV3Provider(recaptchaSiteKey),
      );
    }
  }
}
