import 'package:flutter/material.dart';
import '../services/login_service.dart'; // Import LoginService
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginService _loginService = LoginService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final user = await _loginService.login(email, password);
    if (user != null) {
      try {
        // Call handleLogin to ensure the user is in the local database
        await _loginService.handleLogin(user.uid);

        // Navigate to the home screen after successful login and local user sync
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(currentUserId: user.uid),
          ),
        );
      } catch (e) {
        print("Error during local sync: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error syncing user data: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Email"),
            TextField(controller: _emailController),
            const SizedBox(height: 12),
            const Text("Password"),
            TextField(controller: _passwordController, obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
