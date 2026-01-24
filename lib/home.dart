import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cat_notebook/add_note.dart';
import 'package:cat_notebook/cubit/note_cubit.dart';
import 'package:cat_notebook/cubit/note_state.dart';
import 'package:cat_notebook/cubit/theme_cubit.dart';
import 'package:cat_notebook/drawer.dart';
import 'package:cat_notebook/edit_note.dart';
import 'package:cat_notebook/note_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();

  Future<void> deleteNoteFromFirestore(NoteModel note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (note.id == null) {
      print("Error: note.id is null, cannot delete");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.id)
          .delete();

      context.read<NoteCubit>().deleteNoteById(note.id!);

      print("Note deleted successfully!");
    } catch (e) {
      print("Failed to delete note: $e");
      rethrow;
    }
  }

  Future<void> deleteAllNotes() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notes')
        .get()
        .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
          }
        });
  }

  @override
  void initState() {
    super.initState();
    context.read<NoteCubit>().loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: drawerKey,
      endDrawer: AppDrawer(),

      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNotePage()),
          );
        },
        backgroundColor: const Color(0xFF009445),
        tooltip: 'Add Note',
        child: Icon(
          Icons.add,
          size: 50,
          color: context.watch<ThemeCubit>().state == ThemeMode.dark
              ? Color(0xFF141414)
              : Color(0xFFF7F5F5),
        ),
      ),

      body: Container(
        width: screenWidth,
        height: screenHeight,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  context.watch<ThemeCubit>().state == ThemeMode.dark
                      ? 'images/logo-title-dark.png'
                      : 'images/logo-title-light.png',
                  width: screenWidth * 0.5,
                ),
                Row(
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Image(
                        image: AssetImage('images/deleteall-icon.png'),
                        width: 30,
                        height: 30,
                      ),
                      onTap: () {
                        final state = context.read<NoteCubit>().state;

                        if (state is NoteLoaded && state.notes.isNotEmpty) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.question,
                            animType: AnimType.scale,
                            title: 'Delete All Notes',
                            desc: 'Are you sure you want to delete all notes?',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () async {
                              await deleteAllNotes();
                              context.read<NoteCubit>().clearNotes();
                            },
                          ).show();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("No notes to delete")),
                          );
                        }
                      },
                    ),
                    SizedBox(width: 18),

                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        drawerKey.currentState!.openEndDrawer();
                      },
                      child: Icon(
                        Icons.menu,
                        size: 40,
                        color:
                            context.watch<ThemeCubit>().state == ThemeMode.dark
                            ? Color(0xFFF7F5F5)
                            : Color(0xFF141414),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: screenWidth,
              height: screenHeight * 0.8,
              decoration: BoxDecoration(
                color: Color(0xFF016838),
                borderRadius: BorderRadius.circular(12),
              ),
              child: BlocBuilder<NoteCubit, NoteState>(
                builder: (context, state) {
                  if (state is NoteInitial) {
                    return Center(
                      child: Text(
                        "No Notes Added",
                        style: TextStyle(
                          color: Color(0xFFF7F5F5),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else if (state is NoteLoaded) {
                    final notes = state.notes;

                    if (notes.isEmpty) {
                      return Center(
                        child: Text(
                          "No Notes Added",
                          style: TextStyle(
                            color: Color(0xFFF7F5F5),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = state.notes[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditNotePage(note: note, index: index),
                                ),
                              );
                            },
                            onLongPress: () {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.question,
                                animType: AnimType.scale,
                                title: 'Delete Note',
                                desc:
                                    'Are you sure you want to delete this note?',
                                btnCancelOnPress: () {},
                                btnOkOnPress: () async {
                                  try {
                                    await deleteNoteFromFirestore(note);
                                    // context.read<NoteCubit>().deleteNote(
                                    //   widget.index,
                                    // );
                                    Navigator.pop(context);
                                  } catch (e) {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.scale,
                                      title: 'Error',
                                      desc: 'Failed to delete note: $e',
                                      btnOkOnPress: () {},
                                    ).show();
                                  }
                                },
                              ).show();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 11,
                                    height: screenHeight * 0.15,
                                    decoration: BoxDecoration(
                                      color: Color(note.color),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        note.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Color(0xFF009445),
                                        ),
                                      ),
                                      subtitle: Text(
                                        note.content,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("Something went wrong"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
