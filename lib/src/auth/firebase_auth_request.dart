import 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';

abstract class FirebaseAuthRequest<T, D extends FirebaseRequestDto> {
  Future<T> execute(D dto);
}
