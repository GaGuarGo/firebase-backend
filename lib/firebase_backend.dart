/// Declarative abstractions over Firestore, Firebase Auth and Firebase
/// Storage: typed endpoints, validated DTOs, transactions and a single error
/// hierarchy.
library;

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// [config]
export 'package:firebase_backend/src/firebase_backend_config.dart';

/// [core]
export 'package:firebase_backend/src/core/firebase_endpoint.dart';

/// [auth]
export 'package:firebase_backend/src/auth/dtos/firebase_signin_dto.dart';
export 'package:firebase_backend/src/auth/dtos/firebase_signup_dto.dart';
export 'package:firebase_backend/src/auth/firebase_auth_listener.dart';
export 'package:firebase_backend/src/auth/firebase_auth_request.dart';
export 'package:firebase_backend/src/auth/firebase_signin_user_request.dart';
export 'package:firebase_backend/src/auth/firebase_signout_user_request.dart';
export 'package:firebase_backend/src/auth/firebase_signup_user_request.dart';

/// [dtos]
export 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';
export 'package:firebase_backend/src/data/dto/firebase_response_dto.dart';

/// [endpoints]
export 'package:firebase_backend/src/data/endpoint/firebase_delete_endpoint.dart';
export 'package:firebase_backend/src/data/endpoint/firebase_get_endpoint.dart';
export 'package:firebase_backend/src/data/endpoint/firebase_post_endpoint.dart';
export 'package:firebase_backend/src/data/endpoint/firebase_stream_endpoint.dart';
export 'package:firebase_backend/src/data/endpoint/firebase_update_endpoint.dart';

/// [transactions]
export 'package:firebase_backend/src/data/transaction/firebase_transaction_context.dart';
export 'package:firebase_backend/src/data/transaction/firebase_transaction_endpoint.dart';

/// [storage]
export 'package:firebase_backend/src/data/storage/firebase_upload_to_storage.dart';

/// [entity]
export 'package:firebase_backend/src/domain/entity/firebase_data_entity.dart';

/// [exceptions]
export 'package:firebase_backend/src/domain/exception/firebase_backend_auth_exception.dart';
export 'package:firebase_backend/src/domain/exception/firebase_backend_exception.dart';
export 'package:firebase_backend/src/domain/exception/firebase_backend_not_found_exception.dart';
export 'package:firebase_backend/src/domain/exception/firebase_backend_storage_exception.dart';
export 'package:firebase_backend/src/domain/exception/firebase_backend_stream_exception.dart';
export 'package:firebase_backend/src/domain/exception/firebase_backend_transaction_exception.dart';
export 'package:firebase_backend/src/domain/exception/firebase_backend_validation_exception.dart';

/// [validation]
export 'package:firebase_backend/src/domain/validation/dto_validation_error.dart';
export 'package:firebase_backend/src/domain/validation/validatable.dart';
export 'package:firebase_backend/src/domain/validation/validators.dart';

/// [handlers]
export 'package:firebase_backend/src/handlers/firebase_auth_code_error_handler.dart';

/// Initializes Firebase for this package, optionally activating App Check.
///
/// Call this once before using any endpoint:
///
/// ```dart
/// await initFirebaseBackend(options: DefaultFirebaseOptions.currentPlatform);
/// ```
///
/// When [appCheck] is true, App Check is activated with the provider matching
/// the current platform:
///
/// * web uses reCAPTCHA v3 and requires [recaptchaSiteKey];
/// * Android uses [providerAndroid], Play Integrity by default;
/// * Apple platforms use [providerApple], Device Check by default.
///
/// Throws [ArgumentError] if App Check is requested on web without a
/// [recaptchaSiteKey].
Future<void> initFirebaseBackend({
  required FirebaseOptions options,
  bool appCheck = false,
  String recaptchaSiteKey = '',
  AndroidAppCheckProvider providerAndroid =
      const AndroidPlayIntegrityProvider(),
  AppleAppCheckProvider providerApple = const AppleDeviceCheckProvider(),
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: options);

  if (!appCheck) return;

  if (kIsWeb) {
    if (recaptchaSiteKey.isEmpty) {
      throw ArgumentError(
        'recaptchaSiteKey must be provided for App Check on web platforms.',
      );
    }

    await FirebaseAppCheck.instance.activate(
      providerWeb: ReCaptchaV3Provider(recaptchaSiteKey),
    );
    return;
  }

  await FirebaseAppCheck.instance.activate(
    providerAndroid: providerAndroid,
    providerApple: providerApple,
  );
}
