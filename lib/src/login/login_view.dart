import 'package:flutter/material.dart';
import 'login_service.dart';

class LoginView extends StatefulWidget {
  static const routeName = '/login';

  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginService _loginService = LoginService();
  String _message = '';
  bool _isLoading = false;

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
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Se connecter'),
                  ),
            const SizedBox(height: 16),
            Text(
              _message,
              style: TextStyle(
                color:
                    _message.startsWith('Failed') ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _message = 'Veuillez remplir tous les champs.';
      });
      return;
    }

    final response = await _loginService.login(email, password);

    if (response['success'] == true) {
      final accessToken = response['access_token'];
      final tokenType = response['token_type'];

      // Affiche le token et le type de token dans le message
      setState(() {
        _isLoading = false;
        _message = 'Connexion réussie!\nToken: $accessToken\nType: $tokenType';
      });

      // Redirection vers la page principale (optionnel si nécessaire)
      // Navigator.of(context).pushReplacementNamed('/');
    } else {
      setState(() {
        _isLoading = false;
        _message = 'Échec de la connexion: ${response['message']}';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
