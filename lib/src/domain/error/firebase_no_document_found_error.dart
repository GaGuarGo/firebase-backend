class FirebaseNoDocumentFoundError implements Exception {
  final String message;

  FirebaseNoDocumentFoundError([this.message = "No document found"]);
}
