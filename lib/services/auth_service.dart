import 'package:supabase_flutter/supabase_flutter.dart';

//https://supabase.com/blog/flutter-authentication
//For validation: https://api.flutter.dev/flutter/dart-core/String/contains.html

class AuthService {
  final supabase = Supabase.instance.client;

  bool validateEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email); // format validating the mail format(something without @)@(something without @).(something without @)
  }

  bool validatePassword(String password) {
    return password.length >= 6 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  String passwordRuleMessage() {
    return 'Use at least 6 characters, one uppercase letter, and one number.';
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpNewUser(String email, String password) async {
    return await supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  String friendlyAuthError(Object error) {
    if (error is! AuthException) {
      return 'Could not connect to the server. Please try again.';
    }

    final message = error.message.toLowerCase();

    // Provide user-friendly error messages based on the error message from Supabase. Used Ai to tell me how thes messages can look like (lost ai chat... By Adrian Slanz)
    if (message.contains('invalid login')) {
      return 'Email or password is incorrect.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email address before logging in.';
    }
    if (message.contains('already registered') ||
        message.contains('already exists')) {
      return 'An account with this email already exists.';
    }

    return 'Authentication failed. Please check your details and try again.';
  }
}