import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_backend/src/auth/firebase_auth_request.dart';
import 'package:firebase_backend/src/data/dto/firebase_request_dto.dart';

class FirebaseSignoutRequest implements FirebaseAuthRequest {
  @override
  Future execute(FirebaseRequestDto dto) async {
    await FirebaseAuth.instance.signOut();
  }
}
