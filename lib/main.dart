import 'package:flutter/material.dart';
import 'package:macrotracker/screens/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//https://www.youtube.com/watch?v=2ADL1eYcu-c this video was used as inspiration
//https://github.com/ShehanAT/flutter_calorie_tracker_app inspiration
Future<void> main() async {
  // Ensure that plugin services are initialized so that `Supabase.initialize` can be called before `runApp`.
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ampxedtveywhirairfnf.supabase.co',
    publishableKey: 'sb_publishable_ivZX5ACEN5Vky2XiUnKCKw_L2jkZWGa',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}