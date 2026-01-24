import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String? id;
  final String title;
  final String content;
  final int color;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    required this.color,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      color: data['color'] ?? 0xFFE53935,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'color': color,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
