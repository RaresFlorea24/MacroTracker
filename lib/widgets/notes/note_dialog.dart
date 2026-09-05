import 'package:flutter/material.dart';

class NoteDialog extends StatelessWidget {
  final String date;
  final String initialText;

  const NoteDialog({
    super.key,
    required this.date,
    required this.initialText,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialText);

    return AlertDialog(
      title: Text('Notes for $date'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 6,
        decoration: const InputDecoration(
          hintText: 'How did the day go?',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}