import 'package:flutter/material.dart';
import 'package:macrotracker/models/food_entry.dart';

class ManualEntryDialog extends StatelessWidget {
  const ManualEntryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final kcalController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    String? nameError;
    String? kcalError;

    
    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Enter food details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  errorText: nameError,
                ),
              ),
              TextField(
                controller: kcalController,
                decoration: InputDecoration(
                  labelText: 'Calories per 100g',
                  errorText: kcalError,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: proteinController,
                decoration: const InputDecoration(
                  labelText: 'Protein per 100g',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: carbsController,
                decoration: const InputDecoration(labelText: 'Carbs per 100g'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: fatController,
                decoration: const InputDecoration(labelText: 'Fat per 100g'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final kcal = double.tryParse(
                kcalController.text.replaceAll(',', '.'),
              );
              final protein = double.tryParse(
                proteinController.text.replaceAll(',', '.'),
              );
              final carbs = double.tryParse(
                carbsController.text.replaceAll(',', '.'),
              );
              final fat = double.tryParse(
                fatController.text.replaceAll(',', '.'),
              );

              // show messages instead of silently doing nothing
              setDialogState(() {
                nameError = name.isEmpty ? 'Please enter a name' : null;
                kcalError = kcal == null
                    ? 'Please enter a number'
                    : kcal <= 0
                    ? 'Must be greater than 0'
                    : null;
              });

              if (nameError != null || kcalError != null) return;

              Navigator.of(context).pop(
                FoodEntry(
                  name: name,
                  kcalPer100g: kcal!,
                  proteinPer100g: protein,
                  carbsPer100g: carbs,
                  fatPer100g: fat,
                  barcode: '',
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
