import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:macrotracker/models/day_data.dart';
import 'package:macrotracker/models/diary_entry.dart';
import 'package:macrotracker/models/food_entry.dart';
import 'package:macrotracker/screens/history_screen.dart';
import 'package:macrotracker/screens/scanner_screen.dart';
import 'package:macrotracker/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:macrotracker/widgets/grams_dialog.dart';
import 'package:macrotracker/widgets/manual_entry_dialog.dart';
import 'package:macrotracker/widgets/notes/note_card.dart';
import 'package:macrotracker/widgets/notes/note_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

//at the moment im missing display total calories per day and the alternative of including your own food entry if the barcode is not found and maybe the option of deleting an entry.
class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  final supabase = Supabase.instance.client;
  DateTime date =
      DateTime.now(); //using this date to get the input per every day, and to filter the entries in the table
  String get dateDisplay => date.toIso8601String().substring(
    0,
    10,
  ); //recommended by autofill totransform it int a getter
  bool isLoading = false; //to show a loading indicator when fetching data
  bool isLooking = false;
  List<DiaryEntry> entries = [];
  String note = '';
  List<DayData> historyData = []; //to store the data for the history chart
  double get totalKcal => entries.fold(
    0.0,
    (sum, e) => sum + e.kcal,
  ); //recommended by autofill when implementing it

  @override
  void initState() {
    super.initState();
    getFoodEntries();
    getNote();
    getHistoryData();
  }

  Future<void> logout() async {
    await authService.signOut();
    // AuthGate swaps back to LoginScreen on its own
  }

  //function used to get the data to populet the history chart
  Future<void> getHistoryData() async {
    final today = DateTime.now();
    final from = today.subtract(const Duration(days: 6));//to get the last 7 days, including today
    final result = <DayData>[];
    try {
      final response = await supabase
          .from('entries')
          .select('date, kcal')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('date', from.toIso8601String().substring(0, 10))
          .lte('date', today.toIso8601String().substring(0, 10));

      final byDay = <String, double>{};
      for (final row in response) {
        final key = row['date'] as String;
        byDay[key] = (byDay[key] ?? 0) + (row['kcal'] as num).toDouble();
      }

      for (var i = 0; i < 7; i++) { //loop through the last 7 days to get the data for the chart
        final day = from.add(Duration(days: i));
        final key = day.toIso8601String().substring(0, 10);
        result.add(DayData(date: day, kcal: byDay[key] ?? 0));
      }
      if (!mounted) return;
      setState(() {
        historyData = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch history data.')),
      );
    }
  }

  //function for shifting the date, to be used in the buttons
  void shiftDate(int days) {
    setState(() {
      date = date.add(Duration(days: days));
    });
    getFoodEntries();
    getNote();
  }

  Future<FoodEntry?> lookupFood(String barcode) async {
    //https://openfoodfacts.github.io/openfoodfacts-server/api/ref-cheatsheet/
    final res = await http.get(
      Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json'),
    );
    if (res.statusCode != 200) return null;

    final product = jsonDecode(res.body)['product'];
    if (product == null) {
      return null;
    } else {
      final kcal = product['nutriments']?['energy-kcal_100g'];
      final protein = product['nutriments']?['proteins_100g'];
      final carbs = product['nutriments']?['carbohydrates_100g'];
      final fat = product['nutriments']?['fat_100g'];
      final name = product['product_name'];
      if (kcal is! num || name is! String || name.isEmpty) return null;

      return FoodEntry(
        name: name,
        kcalPer100g: kcal.toDouble(),
        proteinPer100g: protein is num ? protein.toDouble() : null,
        carbsPer100g: carbs is num ? carbs.toDouble() : null,
        fatPer100g: fat is num ? fat.toDouble() : null,
        barcode: barcode,
      );
    }
  }

  //function used when the barcode is scanned and the return is null
  Future<FoodEntry?> askManualEntry() {
    return showDialog<FoodEntry>(
      context: context,
      builder: (_) => const ManualEntryDialog(),
    );
  }

  // Returns the grams the user typed, or null if they cancelled.
  Future<double?> askGrams(String name) {
    return showDialog<double>(
      context: context,
      builder: (_) => GramsDialog(name: name),
    );
  }

  //function that adds the scanned/entered food into the table, and also calculates the total kcal, protein, carbs and fats based on the grams entered by the user
  Future<void> addFoodEntry() async {
    final barcode = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const ScannerScreen()));
    if (barcode == null || !mounted) return;

    setState(() {
      isLooking = true;
    });
    var foodEntry = await lookupFood(barcode);
    if (!mounted) return;
    setState(() {
      isLooking = false;
    });

    if (foodEntry == null) {
      foodEntry =
          await askManualEntry(); //if the barcode is not found, ask the user to enter the food details manually
      if (foodEntry == null) {
        return; //if the user cancels the manual entry, return
      }
    }

    final grams = await askGrams(foodEntry.name);
    if (grams == null) return;

    final kcal = foodEntry.kcalPer100g * grams / 100;

    //using those to not get errors in case its empty
    final protein = foodEntry.proteinPer100g != null
        ? foodEntry.proteinPer100g! * grams / 100
        : null;
    final carbs = foodEntry.carbsPer100g != null
        ? foodEntry.carbsPer100g! * grams / 100
        : null;
    final fat = foodEntry.fatPer100g != null
        ? foodEntry.fatPer100g! * grams / 100
        : null;

    //prevoiusly created the table in supabase with those parameters, later i want to do filtering on the date.
    try {
      await supabase.from('entries').insert({
        'user_id': supabase.auth.currentUser!.id,
        'name': foodEntry.name,
        'grams': grams,
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fats': fat,
        'date': date.toIso8601String().substring(0, 10), //to get better date
      });
      await getFoodEntries(); //will need this to show the updated list
      await getHistoryData(); //to update the history chart after adding a new entry
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add food entry.'),
        ), //recommended by autofill
      );
    }
  }

  //fetches the note from the database for a specific day
  Future<void> getNote() async {
    try {
      final row = await supabase
          .from('notes')
          .select('body')
          .eq('date', dateDisplay)
          .maybeSingle();

      if (!mounted) return;
      setState(() => note = (row?['body'] as String?) ?? '');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch note: $e')));
    }
  }

  //used the same logic as in the addFoodEntry function, but this time to edit the note for the specific day
  Future<void> editNote() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => NoteDialog(date: dateDisplay, initialText: note),
    );

    if (result == null) return;

    try {
      await supabase.from('notes').upsert({
        'user_id': supabase.auth.currentUser!.id,
        'date': dateDisplay,
        'body': result,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,date');

      if (!mounted) return;
      setState(() => note = result);
    } catch (e) {
      debugPrint('note save failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save note: $e')));
    }
  }

  //the function do get all the entries from the table at load time
  Future<void> getFoodEntries() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await supabase
          .from('entries')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('date', dateDisplay);

      //the implementation idea was mine, I just asked claude how should the syntax look like
      setState(() {
        entries = response
            .map(
              (row) => DiaryEntry(
                name: row['name'],
                kcal: (row['kcal'] as num).toDouble(),
                grams: (row['grams'] as num).toDouble(),
                protein: (row['protein'] as num?)?.toDouble(),
                carbs: (row['carbs'] as num?)?.toDouble(),
                fat: (row['fats'] as num?)?.toDouble(),
              ),
            )
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch food entries.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 35,
            ),
            const Text('MacroTracker'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          if (isLooking) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                IconButton(
                  onPressed: () => shiftDate(-1),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Previous day',
                ),
                Text(dateDisplay),
                IconButton(
                  onPressed: () => shiftDate(1),
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Next day',
                ),
                Text(
                  '${totalKcal.round()} kcal',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          isLoading
              ? const LinearProgressIndicator()
              : NoteCard(note: note, onTap: editNote),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : entries.isEmpty
                ? const Center(child: Text('No food entries for this day.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final e = entries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(e.name),
                          subtitle: Text(
                            [
                              '${e.grams.round()} g',
                              if (e.protein != null) 'P ${e.protein!.round()}',
                              if (e.carbs != null) 'C ${e.carbs!.round()}',
                              if (e.fat != null) 'F ${e.fat!.round()}',
                            ].join(' · '),
                          ),
                          trailing: Text(
                            '${e.kcal.round()} kcal',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'history',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryChart(data: historyData),
                ),
              );
            },
            child: const Icon(Icons.history),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: addFoodEntry,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
