import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/compte_rendus_model.dart';
import '../../auth/auth_service.dart';

class CompteRendusService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService(); // Instance de AuthService
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000';

  Future<void> addCompteRendu(CompteRendu compteRendu) async {
    try {
      // Récupérer le token JWT
      final token = await _authService.getJwtToken();
      if (token == null || await _authService.isTokenExpired()) {
        throw Exception('Token invalide ou expiré');
      }

      // Effectuer la requête avec le token JWT
      final response = await _dio.post(
        '$_baseUrl/rapports/',
        data: compteRendu.toMap(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Erreur lors de l\'ajout du compte-rendu');
      }
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  Future<List<CompteRendu>> getAllCompteRendus() async {
    try {
      // Récupérer le token JWT
      final token = await _authService.getJwtToken();
      if (token == null || await _authService.isTokenExpired()) {
        throw Exception('Token invalide ou expiré');
      }

      // Effectuer la requête avec le token JWT
      final response = await _dio.get(
        '$_baseUrl/rapports/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => CompteRendu.fromMap(item)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des comptes-rendus');
      }
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }
}
