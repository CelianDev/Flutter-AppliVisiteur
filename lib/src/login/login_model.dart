import 'package:flutter/material.dart';
import 'login_service.dart';

class LoginModel extends ChangeNotifier {
  final LoginService _loginService;
  bool _isLoading = false;
  String _message = '';

  bool get isLoading => _isLoading;
  String get message => _message;

  LoginModel(this._loginService);

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _message = 'Veuillez remplir tous les champs.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _message = '';
    notifyListeners();

    final response = await _loginService.login(email, password);

    if (response['success'] == true) {
      _message =
          'Connexion réussie!\nToken: ${response['access_token']}\nType: ${response['token_type']}';
    } else {
      _message = 'Échec de la connexion: ${response['message']}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
