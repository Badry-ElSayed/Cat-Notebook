import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cat_notebook/cubit/note_cubit.dart';
import 'package:cat_notebook/cubit/theme_cubit.dart';
import 'package:cat_notebook/drawer.dart';
import 'package:cat_notebook/note_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  GlobalKey<FormState> formKey = GlobalKey();
  GlobalKey<ScaffoldState> drawerKey = GlobalKey();
  late TextEditingController titleController;
  late TextEditingController noteController;
  int selectedColor = 0xFFE53935;
  final List<int> colors = [
    0xFFE53935, // red
    0xFFFFB74D, // orange
    0xFF29B6F6, // blue
    0xFF283593, // dark blue
    0xFF8E24AA, // purple
  ];

  Future<void> addNoteToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes');

    final docRef = notesCollection.doc();

    docRef.set({
      'title': titleController.text,
      'content': noteController.text,
      'color': selectedColor,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final note = NoteModel(
      id: docRef.id,
      title: titleController.text,
      content: noteController.text,
      color: selectedColor,
    );
    context.read<NoteCubit>().addNote(note);
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    noteController = TextEditingController();
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
                  InkWell(
                    child: Icon(
                      Icons.menu,
                      size: 38,
                      color: context.watch<ThemeCubit>().state == ThemeMode.dark
                          ? Color(0xFFF7F5F5)
                          : Color(0xFF141414),
                    ),
                    onTap: () {
                      drawerKey.currentState?.openEndDrawer();
                    },
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
                          onTap: () async {
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
                            try {
                              await addNoteToFirestore();
                              Navigator.pop(context);
                            } catch (e) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.scale,
                                title: 'Error',
                                desc: 'Failed to save note: $e',
                                btnOkOnPress: () {},
                              ).show();
                            }
                          },
                          child: Text(
                            "Create Note",
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
