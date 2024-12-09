import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _jwtKey = 'jwt_token';

  /// Récupérer le JWT stocké
  Future<String?> getJwtToken() async {
    try {
      return await _storage.read(key: _jwtKey);
    } catch (e) {
      // Gérer les erreurs de lecture si nécessaire
      return null;
    }
  }

  /// Vérifier si le token est expiré
  Future<bool> isTokenExpired() async {
    String? token = await getJwtToken();
    if (token == null) {
      return true;
    }
    return JwtDecoder.isExpired(token);
  }

  /// Supprimer le JWT (lors de la déconnexion par exemple)
  Future<void> deleteJwtToken() async {
    try {
      await _storage.delete(key: _jwtKey);
    } catch (e) {
      // Gérer les erreurs de suppression si nécessaire
    }
  }

  /// Effectuer une requête GET vers un endpoint protégé
  Future<Response?> getProtectedData(String endpoint) async {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null) {
      throw Exception('API URL is not set');
    }

    String? token = await getJwtToken();
    if (token == null || await isTokenExpired()) {
      throw Exception('Token invalide ou expiré');
    }

    try {
      final response = await _dio.get(
        '$apiUrl$endpoint',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response;
    } catch (e) {
      // Gérer les erreurs de requête
      rethrow;
    }
  }

  /// Vous pouvez également ajouter des méthodes pour POST, PUT, DELETE si nécessaire
}
