import 'package:dio/dio.dart';
import 'package:transi_flex_mobile/app_config.dart';
import 'package:transi_flex_mobile/authentification/service/auth_service.dart';

import '../../core/exceptions.dart';
import '../model/mobile_app.dart';

abstract class MobileAppDataSource {
  Future<MobileApp> getMobileAppState();
}

class MobileAppDataSourceImpl implements MobileAppDataSource {
  final Dio client;
  final AuthService authService;

  MobileAppDataSourceImpl({
    required this.client,
    required this.authService
  });

  @override
  Future<MobileApp> getMobileAppState() async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        '${AppConfig.apiUrl}/mobile-app',
        options: Options(
          headers:headers,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        return MobileApp.fromJson(jsonResponse);
      } else {
        final errorResponse = response.data;
        throw ServerException(
          message: errorResponse['message'] ?? 'Erreur serveur',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Erreur Dio',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw NetworkException(
        message: 'Erreur de réseau: ${e.toString()}',
      );
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await authService.getToken();

    if (token == null || token.isEmpty) {
      throw ServerException(
        message: 'Token d\'authentification manquant',
        statusCode: 401,
      );
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}