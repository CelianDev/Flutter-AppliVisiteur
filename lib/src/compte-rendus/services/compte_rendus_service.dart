import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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

      // Configurer Dio pour le débogage
      _dio.interceptors.clear();
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));

      // Préparer les données pour l'API
      final data = compteRendu.toMap();
      print('Données envoyées à l\'API: ${jsonEncode(data)}');

      // Effectuer la requête avec le token JWT
      final response = await _dio.post(
        '$_baseUrl/rapports/',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) =>
              true, // Accepter tous les codes de statut pour débogage
        ),
      );

      print('Code de statut: ${response.statusCode}');
      print('Réponse du serveur: ${response.data}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
            'Erreur lors de l\'ajout du compte-rendu: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Exception détaillée: $e');
      if (e is DioException) {
        final dioError = e;
        print('Type d\'erreur Dio: ${dioError.type}');
        print('Message d\'erreur: ${dioError.message}');
        print('Code de statut: ${dioError.response?.statusCode}');
        print('Données de réponse: ${dioError.response?.data}');

        if (dioError.response?.statusCode == 422) {
          throw Exception('Données invalides: ${dioError.response?.data}');
        }
      }
      throw Exception('Erreur lors de la création du compte-rendu: $e');
    }
  }

  Future<List<CompteRenduList>> getAllCompteRendus() async {
    try {
      // Récupérer le token JWT
      final token = await _authService.getJwtToken();
      if (token == null || await _authService.isTokenExpired()) {
        throw Exception('Token invalide ou expiré');
      }

      // Décoder le token pour obtenir l'UUID de l'utilisateur
      final decodedToken = JwtDecoder.decode(token);
      final uuid = decodedToken[
          'sub']; // 'sub' est généralement l'identifiant de l'utilisateur

      if (uuid == null) {
        throw Exception('Impossible de récupérer l\'UUID de l\'utilisateur');
      }

      // Effectuer la requête avec le token JWT pour récupérer les rapports de l'utilisateur connecté
      final response = await _dio.get(
        '$_baseUrl/rapports/visiteur/$uuid',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => CompteRenduList.fromMap(item)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des comptes-rendus: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception lors de la récupération des comptes-rendus: $e');
      if (e is DioException) {
        final dioError = e;
        print('Type d\'erreur Dio: ${dioError.type}');
        print('Message d\'erreur: ${dioError.message}');
        print('Code de statut: ${dioError.response?.statusCode}');
        print('Données de réponse: ${dioError.response?.data}');
      }
      throw Exception('Erreur lors de la récupération des comptes-rendus: $e');
    }
  }
}
