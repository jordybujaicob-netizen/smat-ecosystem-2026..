import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService().login(
      _userController.text.trim(),
      _passController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      setState(() {
        _errorMessage = "Usuario o clave incorrectos";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          // CORREGIDO: En Flutter el ancho máximo se define con BoxConstraints
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Clave',
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Text('Ingresar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
