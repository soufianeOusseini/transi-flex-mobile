import 'package:dio/dio.dart';
import 'package:transi_flex_mobile/app_config.dart';
import 'package:transi_flex_mobile/authentification/service/auth_service.dart';
import 'package:transi_flex_mobile/core/exceptions.dart';
import 'package:transi_flex_mobile/client/model/colis.dart';

abstract class ColisDataSource {
  Future<List<Colis>> getColisByUser();
  Future<Colis> createColis(Colis colis);
  Future<Colis> updateColis(Colis colis);
  Future<void> deleteColis(int colisId);
}

class ColisDataSourceImpl implements ColisDataSource {
  final Dio client;
  final AuthService authService;

  ColisDataSourceImpl({
    required this.client,
    required this.authService,
  });

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

  String _getApiUrl() => '${AppConfig.apiUrl}/colis';

  @override
  Future<List<Colis>> getColisByUser() async {
    try {
      final headers = await _getHeaders();

      print('📦 Récupération des colis utilisateur');

      final response = await client.get(
        '${_getApiUrl()}/user-colis',
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data ?? [];
        print('✅ ${jsonList.length} colis trouvés');
        return jsonList
            .map((json) => Colis.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur lors de la récupération des colis',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur getColisByUser: ${e.message}');
      if (e.response?.statusCode == 401) {
        await authService.removeTokens();
      }
      throw ServerException(
        message: e.message ?? 'Erreur de communication',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('❌ Erreur: $e');
      throw NetworkException(message: 'Erreur de réseau: ${e.toString()}');
    }
  }

  @override
  Future<Colis> createColis(Colis colis) async {
    try {
      final headers = await _getHeaders();

      print('📦 Création d\'un colis');
      print('Colis: ${colis.toJson()}');

      final response = await client.post(
       '${_getApiUrl()}',
        data: colis.toJson(),
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Colis créé avec succès');
        return Colis.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur lors de la création',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur createColis: ${e.message}');
      print('Response: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        await authService.removeTokens();
      }
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Erreur de communication',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('❌ Erreur: $e');
      throw NetworkException(message: 'Erreur de réseau: ${e.toString()}');
    }
  }

  @override
  Future<Colis> updateColis(Colis colis) async {
    try {
      final headers = await _getHeaders();

      print('📦 Modification du colis ${colis.id}');

      final response = await client.put(
        '${_getApiUrl()}/${colis.id}',
        data: colis.toJson(),
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Colis modifié avec succès');
        return Colis.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur lors de la modification',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur updateColis: ${e.message}');
      if (e.response?.statusCode == 401) {
        await authService.removeTokens();
      }
      throw ServerException(
        message: e.message ?? 'Erreur de communication',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('❌ Erreur: $e');
      throw NetworkException(message: 'Erreur de réseau: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteColis(int colisId) async {
    try {
      final headers = await _getHeaders();

      print('📦 Suppression du colis $colisId');

      final response = await client.delete(
        '${_getApiUrl()}/$colisId',
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Colis supprimé avec succès');
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur lors de la suppression',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur deleteColis: ${e.message}');
      if (e.response?.statusCode == 401) {
        await authService.removeTokens();
      }
      throw ServerException(
        message: e.message ?? 'Erreur de communication',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('❌ Erreur: $e');
      throw NetworkException(message: 'Erreur de réseau: ${e.toString()}');
    }
  }
}