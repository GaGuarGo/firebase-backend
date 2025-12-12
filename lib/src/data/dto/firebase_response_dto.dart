import 'package:firebase_backend/src/domain/entity/firebase_data_entity.dart';

abstract class FirebaseResponseDto<T extends FirebaseDataEntity> {
  /// Creates a FirebaseResponseDto from a JSON-compatible map.
  FirebaseResponseDto fromJson(Map<String, dynamic> json);

  /// Converts the DTO to its corresponding entity representation.
  T toEntity();
}

class FirebaseNoResponseDto extends FirebaseResponseDto<FirebaseNoDataEntity> {
  @override
  fromJson(Map<String, dynamic> json) {
    return this;
  }

  @override
  FirebaseNoDataEntity toEntity() => FirebaseNoDataEntity();
}
