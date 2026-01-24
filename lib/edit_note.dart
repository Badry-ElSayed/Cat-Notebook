import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cat_notebook/cubit/note_cubit.dart';
import 'package:cat_notebook/cubit/theme_cubit.dart';
import 'package:cat_notebook/drawer.dart';
import 'package:cat_notebook/note_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditNotePage extends StatefulWidget {
  const EditNotePage({super.key, required this.note, required this.index});
  final NoteModel note;
  final int index;

  @override
  State<EditNotePage> createState() => EditNotePageState();
}

class EditNotePageState extends State<EditNotePage> {
  GlobalKey<FormState> formKey = GlobalKey();
  GlobalKey<ScaffoldState> drawerKey = GlobalKey();
  late TextEditingController titleController;
  late TextEditingController noteController;
  late int selectedColor = widget.note.color;
  final List<int> colors = [
    0xFFE53935, // red
    0xFFFFB74D, // orange
    0xFF29B6F6, // blue
    0xFF283593, // dark blue
    0xFF8E24AA, // purple
  ];

  Future editNoteInFirestore(NoteModel note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (note.id == null) {
      print("Error: note.id is null, cannot edit");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.id)
          .update({
            'title': note.title,
            'content': note.content,
            'color': note.color,
          });

      print("Note edited successfully!");
    } catch (e) {
      print("Failed to edit note: $e");
      rethrow;
    }
  }

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

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    noteController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: drawerKey,
      endDrawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Container(
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
                        child: Image(
                          image: AssetImage('images/delete-icon.png'),
                          width: 30,
                          height: 30,
                        ),
                        onTap: () {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.question,
                            animType: AnimType.scale,
                            title: 'Delete Note',
                            desc: 'Are you sure you want to delete this note?',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () async {
                              try {
                                await deleteNoteFromFirestore(widget.note);
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
                      ),
                      SizedBox(width: 18),
                      InkWell(
                        onTap: () {
                          drawerKey.currentState!.openEndDrawer();
                        },
                        child: Icon(
                          Icons.menu,
                          size: 40,
                          color:
                              context.watch<ThemeCubit>().state ==
                                  ThemeMode.dark
                              ? Color(0xFFF7F5F5)
                              : Color(0xFF141414),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 8),
              Container(height: 5, color: Color(0xFF009445)),
              SizedBox(height: 20),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.all(12),
                width: screenWidth,
                height: screenHeight * 0.7,
                decoration: BoxDecoration(
                  color: Color(0xFF009445),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFF016838), width: 10),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Title",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF7F5F5),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: titleController,
                            style: TextStyle(
                              color: Color(0xFF009445),
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: "Enter Title",
                              hintStyle: TextStyle(fontSize: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Color(0xFFF7F5F5),
                            ),
                            validator: (value) => null,
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Subject",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF7F5F5),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: noteController,
                            style: TextStyle(
                              color: Color(0xff000000),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: "Enter subject",
                              hintStyle: TextStyle(fontSize: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Color(0xFFF7F5F5),
                            ),
                            maxLines: 7,
                            validator: (value) => null,
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: colors.map((color) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Color(color),
                                child: selectedColor == color
                                    ? Icon(Icons.check, color: Colors.white)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: 12),

                      Container(
                        width: 150,
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFF016838),
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (titleController.text.trim().isEmpty ||
                                noteController.text.trim().isEmpty) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.scale,
                                title: 'Missing Data',
                                desc:
                                    'Please fill all fields before saving the note.',
                                btnOkOnPress: () {},
                              ).show();

                              return;
                            }

                            final note = NoteModel(
                              title: titleController.text,
                              content: noteController.text,
                              color: selectedColor,
                              id: widget.note.id,
                            );
                            editNoteInFirestore(note);
                            context.read<NoteCubit>().editNote(
                              widget.index,
                              note,
                            );
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Save Changes",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'images/back-to-home.png',
                    width: screenWidth * 0.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
