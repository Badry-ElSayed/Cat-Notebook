
 class NoteState {}

class NoteInitial extends NoteState {}

class NoteLoaded extends NoteState {
  final List notes;

  NoteLoaded(this.notes);
}
