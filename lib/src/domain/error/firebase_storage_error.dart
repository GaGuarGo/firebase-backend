
class FirebaseStorageError implements Exception {
  final String message;

  FirebaseStorageError(this.message);

  @override
  String toString() => 'FirebaseStorageError: $message';
  
}