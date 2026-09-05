
import 'package:flutter/material.dart';
import 'package:macrotracker/screens/app_screen.dart';
import 'package:macrotracker/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//info, logic and structure from lecture 10
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      body: StreamBuilder(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Show a loading indicator while waiting for the auth state to be determined.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // The canvas is only reachable while Supabase has an active session.
          final session = snapshot.data?.session;
          return session == null ? const LoginScreen() : const HomeScreen();
        },
      ),
    );
  }
}