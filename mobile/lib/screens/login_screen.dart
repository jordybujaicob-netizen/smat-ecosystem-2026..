import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final success = await AuthService().login(
      _userController.text.trim(),
      _passController.text.trim(),
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario o clave incorrectos")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")), // Aquí sale la palabra Login
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "Usuario")),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: "Clave"), obscureText: true),
            const SizedBox(height: 30),
            _isLoading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(onPressed: _handleLogin, child: const Text("Ingresar")),
          ],
        ),
      ),
    );
  }
}