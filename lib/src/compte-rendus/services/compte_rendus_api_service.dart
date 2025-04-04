import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/praticien_model.dart';
import '../../auth/auth_service.dart';

class CompteRendusApiService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService(); // Instance de AuthService
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000';

  Future<List<Praticien>> fetchPraticiens() async {
    try {
      // Récupérer le token JWT
      final token = await _authService.getJwtToken();
      if (token == null || await _authService.isTokenExpired()) {
        throw Exception('Token invalide ou expiré');
      }

      // Effectuer la requête avec le token JWT
      final response = await _dio.get(
        '$_baseUrl/praticiens/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        
        // Ajouter des logs pour déboguer les IDs des praticiens
        print('Données des praticiens reçues: $data');
        
        final praticiens = data.map((item) {
          // Vérifier que l'ID est correctement extrait
          print('ID du praticien: ${item['id']}');
          return Praticien.fromMap(item);
        }).toList();
        
        // Vérifier les IDs après conversion
        for (var p in praticiens) {
          print('Praticien après conversion - ID: ${p.id}, Nom: ${p.nom} ${p.prenom}');
        }
        
        return praticiens;
      } else {
        throw Exception('Erreur lors de la récupération des praticiens');
      }
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMedicaments() async {
    try {
      // Récupérer le token JWT
      final token = await _authService.getJwtToken();
      if (token == null || await _authService.isTokenExpired()) {
        throw Exception('Token invalide ou expiré');
      }

      // Effectuer la requête avec le token JWT
      final response = await _dio.get(
        '$_baseUrl/medicaments/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Erreur lors de la récupération des médicaments');
      }
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }
}
