import 'package:flutter/material.dart';

//class to take place of the askGrams function in main app, using the same logic, just added a bit of validation
class GramsDialog extends StatelessWidget {
  final String name;

  const GramsDialog({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    String? error;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        void submit() {
          final grams = double.tryParse(controller.text.replaceAll(',', '.'));

          setDialogState(() {
            error = grams == null
                ? 'Please enter a number'
                : grams <= 0
                    ? 'Must be greater than 0'
                    : null;
          });

          if (error != null) return;
          Navigator.of(context).pop(grams);
        }

        return AlertDialog(
          title: Text('How many grams of $name did you consume?'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              suffixText: 'g',
              errorText: error,
            ),
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(onPressed: submit, child: const Text('Add')),
          ],
        );
      },
    );
  }
}