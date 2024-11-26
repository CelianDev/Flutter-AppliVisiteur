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
  bool _isLoading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F1FA), // Arrière-plan bleu clair
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 400), // Largeur maximale pour les grands écrans
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo_gsb.png', // Assurez-vous que l'image est dans le dossier assets et est déclarée dans pubspec.yaml
                  height: 100,
                ),
                const SizedBox(height: 40),
                // Champ Email
                Theme(
                  data: Theme.of(context).copyWith(
                    primaryColor: const Color(
                        0xFF2B547E), // Couleur du texte du label en focus
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(
                        color: Color(0xFF66A2D3),
                        fontWeight: FontWeight.bold,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color:
                              Color(0xFF66A2D3), // Couleur bleu pour le focus
                          width: 2.0,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 16),
                // Champ Mot de passe
                Theme(
                  data: Theme.of(context).copyWith(
                    primaryColor: const Color(
                        0xFF2B547E), // Couleur du texte du label en focus
                  ),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(
                        color: Color(0xFF66A2D3),
                        fontWeight: FontWeight.bold,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color:
                              Color(0xFF66A2D3), // Couleur bleu pour le focus
                          width: 2.0,
                        ),
                      ),
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 24),
                // Bouton de connexion
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2B547E), // Couleur bleu foncé
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white, // Couleur du texte en blanc
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                // Message d'erreur ou de succès
                Text(
                  _message,
                  style: TextStyle(
                    color: _message.startsWith('Échec')
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ),
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

    setState(() {
      _isLoading = false;
      if (response['success'] == true) {
        _message = 'Connexion réussie !';

        // Redirection vers HomeView
        Navigator.of(context).pushReplacementNamed('/'); // Route de HomeView
      } else {
        _message = 'Échec de la connexion : Email ou mot de passe incorrect.';
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
