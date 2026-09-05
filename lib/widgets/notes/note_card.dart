import 'package:flutter/material.dart';

//same logic from the app, just moved it here for better achitecture.
class NoteCard extends StatelessWidget {
  final String note;
  final VoidCallback onTap; // this will be the editNote function

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.notes),
        title: Text(
          note.isEmpty ? 'Add a note for this day' : note,
          style: note.isEmpty
              ? TextStyle(color: Theme.of(context).colorScheme.outline)
              : null,
        ),
        onTap: onTap,
      ),
    );
  }
}