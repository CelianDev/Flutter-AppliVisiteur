import 'package:flutter/material.dart';
import 'login_service.dart'; // Assurez-vous d'importer votre service

class LoginView extends StatefulWidget {
  static const routeName = '/login';

  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController(); // Remplacez par email
  final _passwordController = TextEditingController();
  final LoginService _loginService = LoginService(); // Instance du service
  String _message = ''; // Pour afficher le message de retour

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Obtenez l'email et le mot de passe depuis les contrôleurs
                String email = _emailController.text;
                String password = _passwordController.text;

                // Appelez le service de connexion avec les données saisies
                String response = await _loginService.login(email, password);

                // Affichez le message de retour de l'API dans l'interface
                setState(() {
                  _message = response;
                });

                // Redirection ou autre logique de connexion
                if (response == 'Login successful') {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
              child: const Text('Se connecter'),
            ),
            const SizedBox(height: 16),
            Text(_message), // Affiche le message renvoyé par l'API
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
