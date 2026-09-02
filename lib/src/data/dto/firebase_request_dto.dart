import 'package:firebase_backend/src/domain/validation/validatable.dart';

/// A validated payload that can be written to Firestore.
///
/// Implement [toJson] with the document body and [onValidate] with the field
/// checks. Endpoints validate the DTO before touching Firebase, so an invalid
/// payload never reaches the network.
abstract class FirebaseRequestDto extends Validatable {
  /// The document body to write to Firestore.
  Map<String, dynamic> toJson();
}

/// A [FirebaseRequestDto] with no payload and nothing to validate.
///
/// Useful for operations that take no input.
class FirebaseNoRequestDto extends FirebaseRequestDto {
  @override
  Map<String, dynamic> toJson() => const {};

  @override
  void onValidate() {}
}
