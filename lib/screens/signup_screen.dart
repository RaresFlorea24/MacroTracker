import 'package:flutter/material.dart';
import 'package:macrotracker/services/auth_service.dart';
import 'package:macrotracker/widgets/password_text_field.dart';

//taken from the last assignament with database

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final password2Controller = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final password2 = password2Controller.text;

    if (email.isEmpty || password.isEmpty || password2.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    if (password != password2) {
      _showMessage('The passwords do not match.');
      return;
    }

    if (!authService.validateEmail(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    if (!authService.validatePassword(password)) {
      _showMessage(authService.passwordRuleMessage());
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final res = await authService.signUpNewUser(email, password);
      if (!mounted) return;
      _showMessage(
        res.session == null
            ? 'Check your inbox to confirm your email, then log in.'
            : 'Account created.',
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      _showMessage(authService.friendlyAuthError(error));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    password2Controller.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text, textAlign: TextAlign.center)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_add_alt_1, size: 56),
                      const SizedBox(height: 16),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign up once, then join the shared canvas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PasswordTextField(controller: passwordController),
                      const SizedBox(height: 16),
                      PasswordTextField(
                        controller: password2Controller,
                        hintText: 'Confirm password',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          onPressed: isLoading ? null : signUp,
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign up',
                                  style: TextStyle(fontSize: 20),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back to login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
