import 'package:cat_notebook/note_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  NoteCubit() : super(NoteInitial());

  void addNote(NoteModel note) {
    if (state is NoteLoaded) {
      final notes = List<NoteModel>.from((state as NoteLoaded).notes);
      notes.add(note);
      emit(NoteLoaded(notes));
    } else {
      emit(NoteLoaded([note]));
    }
  }

  void editNote(int index, NoteModel updatedNote) {
    if (state is NoteLoaded) {
      final notes = List<NoteModel>.from((state as NoteLoaded).notes);
      notes[index] = updatedNote;
      emit(NoteLoaded(notes));
    }
  }

  void deleteNoteById(String id) {
    if (state is NoteLoaded) {
      final notes = List<NoteModel>.from((state as NoteLoaded).notes);
      notes.removeWhere((note) => note.id == id);
      if (notes.isEmpty) {
        emit(NoteInitial());
      } else {
        emit(NoteLoaded(notes));
      }
    }
  }

  void clearNotes() {
    emit(NoteInitial());
  }

  void loadNotes() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final notes = snapshot.docs
              .map((doc) => NoteModel.fromFirestore(doc))
              .toList();
          emit(NoteLoaded(notes));
        });
  }
}
