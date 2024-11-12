import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginService {
  final Dio _dio = Dio();

  Future<String> login(String email, String password) async {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null) {
      return 'API URL is not set';
    }

    try {
      final response = await _dio.post(
        '$apiUrl/auth/login', // Utilisez l'URL de l'API récupérée
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'email': email, // Utilisez 'email' au lieu de 'Username'
          'password': password, // Utilisez 'password' au lieu de 'Password'
        },
      );
      return response.data['message'] ?? 'Login successful';
    } catch (e) {
      return 'Failed to login: ${e.toString()}';
    }
  }
}
