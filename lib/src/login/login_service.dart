import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginService {
  final Dio _dio = Dio();

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

      // Supposons que la réponse contient 'access_token' et 'token_type'
      if (response.statusCode == 200) {
        return {
          'success': true,
          'access_token': response.data['access_token'],
          'token_type': response.data['token_type'],
        };
      } else {
        return {
          'success': false,
          'message': 'Unexpected response status: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 422) {
        return {
          'success': false,
          'message': e.response?.data['detail']
                  ?.map((detail) => detail['msg'])
                  .join(', ') ??
              'Validation error',
        };
      } else {
        return {
          'success': false,
          'message': e.message,
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
