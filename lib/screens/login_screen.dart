
import 'package:flutter/material.dart';
import 'package:macrotracker/screens/signup_screen.dart';
import 'package:macrotracker/services/auth_service.dart';
import 'package:macrotracker/widgets/password_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService = AuthService();

  bool isLoading = false;

  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in all fields.');
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
      await authService.signInWithEmail(email, password);
      _showMessage('Welcome back, $email.');
    } catch (error) {
      _showMessage(authService.friendlyAuthError(error));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  //this is called eveytime we want to pop a snackBar for eficiency
  void _showMessage(String text) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text, textAlign: TextAlign.center)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 300,
                height: 140,
              ),
              const Text(
                'MacroTracker',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                obscureText: false,
                decoration: const InputDecoration(
                  hintText: 'E-Mail',
                  fillColor: Colors.grey,
                  filled: true,
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              PasswordTextField(controller: passwordController),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  fixedSize: const Size.fromWidth(double.maxFinite),
                ),
                onPressed: isLoading ? null : signIn,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No account yet? '),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Create one'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}