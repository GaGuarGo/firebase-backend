import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Exporting all necessary components of the Firebase backend package
/// [auth]
export 'package:firebase_backend/src/auth/firebase_auth_listener.dart';

/// [dto`s]
export 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';
export 'package:firebase_backend/src/data/dto/firebase_response_dto.dart';

/// [endpoint]
export 'package:firebase_backend/src/data/endpoint/firebase_delete_endpoint.dart';
export 'package:firebase_backend/src/data/endpoint/firebase_get_endpoint.dart';
export 'package:firebase_backend/src/data/endpoint/firebase_post_endpoint.dart';
export 'package:firebase_backend/src/data/endpoint/firebase_update_endpoint.dart';

/// ['entity']
export 'package:firebase_backend/src/domain/entity/firebase_data_entity.dart';

/// [error]
export 'package:firebase_backend/src/domain/error/firebase_no_document_found_error.dart';
export 'package:firebase_backend/src/domain/error/firebase_request_dto_validation_error.dart';
export 'package:firebase_backend/src/domain/error/dto_validation_error.dart';
export 'package:firebase_backend/src/domain/error/firebase_auth_error.dart';

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
