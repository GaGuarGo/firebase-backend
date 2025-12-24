class FirebaseStreamError implements Exception {
  final String message;

  FirebaseStreamError(this.message);

  @override
  String toString() => message;
}
