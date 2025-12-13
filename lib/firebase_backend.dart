import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
