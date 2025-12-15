import 'package:firebase_backend/src/domain/entity/firebase_data_entity.dart';

abstract class FirebaseResponseDto<T extends FirebaseDataEntity> {
  /// Converts the DTO to its corresponding entity representation.
  T toEntity();
}

class FirebaseNoResponseDto extends FirebaseResponseDto<FirebaseNoDataEntity> {
  @override
  FirebaseNoDataEntity toEntity() => FirebaseNoDataEntity();
}
