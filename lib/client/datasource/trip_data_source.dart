import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:transi_flex_mobile/app_config.dart';
import 'package:transi_flex_mobile/authentification/service/auth_service.dart';
import 'package:transi_flex_mobile/client/model/trip_result.dart';
import 'package:transi_flex_mobile/core/exceptions.dart';



abstract class TripSearchDataSource {
  Future<List<TripResult>> searchTrips({
    required String villeDepart,
    required String villeArrive,
    required DateTime dateDepart,
    required TimeOfDay heureDepart,
    required int nombrePassagers,
  });

  Future<List<String>> getDepartureCities();

  Future<List<String>> getArrivalCities(String villeDepart);
}

class TripSearchDataSourceImpl implements TripSearchDataSource {
  final Dio client;
  final AuthService authService;

  TripSearchDataSourceImpl({
    required this.client,
    required this.authService,
  });

  Future<String?> _getToken() async {
    try {
      return authService.getToken();
    } catch (e) {
      print('Erreur récupération token: $e');
      return null;
    }
  }

  Future<String> _getApiUrl() async {
    return '${AppConfig.apiUrl}/trip-schedules';
  }

  @override
  Future<List<TripResult>> searchTrips({
    required String villeDepart,
    required String villeArrive,
    required DateTime dateDepart,
    required TimeOfDay heureDepart,
    required int nombrePassagers,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw ServerException(
          message: 'Token d\'authentification manquant',
          statusCode: 401,
        );
      }

      final heureDepString =
          '${heureDepart.hour.toString().padLeft(2, '0')}:${heureDepart.minute.toString().padLeft(2, '0')}';

      final payload = {
        'villeDepart': villeDepart,
        'villeArrive': villeArrive,
        'dateDepart': dateDepart.toIso8601String().split('T')[0],
        'heureDepart': heureDepString,
        'nombrePassagers': nombrePassagers,
      };

      print('🔍 Recherche avec token: ${token.substring(0, 20)}...');
      print('📦 Payload: $payload');

      final response = await client.post(
        '${await _getApiUrl()}/search',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data ?? [];
        print('✅ Résultats: ${jsonList.length} trajets trouvés');
        return jsonList
            .map((json) => TripResult.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur lors de la recherche',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur Dio: ${e.type} - ${e.message}');
      print('Status: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw ServerException(
          message: 'Token invalide ou expiré. Veuillez vous reconnecter.',
          statusCode: 401,
        );
      }

      throw ServerException(
        message: e.message ?? 'Erreur Dio',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('❌ Erreur générale: $e');
      throw NetworkException(
        message: 'Erreur de réseau: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<String>> getDepartureCities() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw ServerException(
          message: 'Token d\'authentification manquant',
          statusCode: 401,
        );
      }

      final response = await client.get(
        '${await _getApiUrl()}/cities/departure',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data ?? [];
        return jsonList.cast<String>();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur lors de la récupération des villes',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur getDepartureCities: ${e.message}');
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

  @override
  Future<List<String>> getArrivalCities(String villeDepart) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw ServerException(
          message: 'Token d\'authentification manquant',
          statusCode: 401,
        );
      }

      final response = await client.get(
        '${await _getApiUrl()}/cities/arrival',
        queryParameters: {'villeDepart': villeDepart},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data ?? [];
        return jsonList.cast<String>();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur lors de la récupération des villes',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur getArrivalCities: ${e.message}');
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


}