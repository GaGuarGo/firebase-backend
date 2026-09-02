import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_backend/firebase_backend.dart';

/// Collection every endpoint double below operates on.
const notesPath = 'notes';

class NoteEntity extends FirebaseDataEntity {
  NoteEntity({required this.id, required this.title, required this.done});

  final String id;
  final String title;
  final bool done;
}

class NoteResponseDto extends FirebaseResponseDto<NoteEntity> {
  NoteResponseDto({required this.id, required this.title, required this.done});

  factory NoteResponseDto.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return NoteResponseDto(
      id: doc.id,
      title: data['title'] as String? ?? '',
      done: data['done'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final bool done;

  @override
  NoteEntity toEntity() => NoteEntity(id: id, title: title, done: done);
}

/// A request DTO with two independently invalid fields, so tests can check
/// that validation reports all of them rather than stopping at the first.
class NoteDto extends FirebaseRequestDto {
  NoteDto({this.title = 'nota', this.done = false, this.author = 'ana'});

  final String title;
  final bool done;
  final String author;

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'done': done,
    'author': author,
  };

  @override
  void onValidate() {
    if (title.isEmpty) addError('title', 'Title não pode ser vazio');
    if (author.isEmpty) addError('author', 'Author não pode ser vazio');
  }
}

class NoteGetEndpoint extends FirebaseGetEndpoint<NoteResponseDto> {
  @override
  String get path => notesPath;

  @override
  NoteResponseDto buildResponse(DocumentSnapshot<Map<String, dynamic>> doc) =>
      NoteResponseDto.fromSnapshot(doc);
}

class NotePostEndpoint extends FirebasePostEndpoint<NoteDto, NoteResponseDto> {
  @override
  String get path => notesPath;

  @override
  NoteResponseDto buildResponse(
    DocumentReference<Map<String, dynamic>> docRef,
    NoteDto requestDto,
  ) => NoteResponseDto(
    id: docRef.id,
    title: requestDto.title,
    done: requestDto.done,
  );
}

class NoteUpdateEndpoint
    extends FirebaseUpdateEndpoint<NoteDto, NoteResponseDto> {
  @override
  String get path => notesPath;

  @override
  NoteResponseDto buildResponse(
    DocumentReference<Map<String, dynamic>> docRef,
    NoteDto requestDto,
  ) => NoteResponseDto(
    id: docRef.id,
    title: requestDto.title,
    done: requestDto.done,
  );
}

class NoteDeleteEndpoint extends FirebaseDeleteEndpoint {
  @override
  String get path => notesPath;
}

class NoteStreamEndpoint extends FirebaseStreamEndpoint<NoteResponseDto> {
  @override
  String get path => notesPath;

  @override
  NoteResponseDto buildResponse(DocumentSnapshot<Map<String, dynamic>> doc) =>
      NoteResponseDto.fromSnapshot(doc);
}

/// Writes a note straight to [db], bypassing the endpoints under test.
Future<void> seedNote(
  FakeFirebaseFirestore db,
  String id, {
  String title = 'nota',
  bool done = false,
  String author = 'ana',
}) => db.collection(notesPath).doc(id).set({
  'title': title,
  'done': done,
  'author': author,
});

/// Reads a note straight from [db], bypassing the endpoints under test.
Future<Map<String, dynamic>?> readNote(FakeFirebaseFirestore db, String id) =>
    db.collection(notesPath).doc(id).get().then((doc) => doc.data());
