import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginService {
  final Dio _dio = Dio();
  final _storage = FlutterSecureStorage();

  /// Clé utilisée pour stocker le JWT dans le stockage sécurisé
  static const String _jwtKey = 'jwt_token';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null) {
      return {'success': false, 'message': 'API URL is not set'};
    }

    try {
      final response = await _dio.post(
        '$apiUrl/auth/login',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data.containsKey('access_token')) {

        // Extraire le JWT du corps de la réponse
         String jwtToken = response.data['access_token'];
        // Stocker le JWT de manière sécurisée
        await _storage.write(key: _jwtKey, value: jwtToken);

        return {
          'success': true,
          // 'access_token': response.data['access_token'],
          // 'token_type': response.data['token_type'],
        };

      } else {
        return {  
          'success': false,
          'message': 'Invalid credentials or unexpected response',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }
}
