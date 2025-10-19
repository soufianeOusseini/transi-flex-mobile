import 'package:dio/dio.dart';
import 'package:transi_flex_mobile/app_config.dart';
import 'package:transi_flex_mobile/authentification/service/auth_service.dart';
import 'package:transi_flex_mobile/core/exceptions.dart';
import 'package:transi_flex_mobile/client/model/ticket.dart';

abstract class TicketDataSource {
  Future<List<Ticket>> getTicketsByUser();
  Future<Ticket> createTicket(Ticket ticket);
  Future<Ticket> confirmReservation(int ticketId, String modePaiement);
  Future<Ticket> cancelTicket(int ticketId);
  Future<List<Ticket>> getTicketsByStatus(String status);
}

class TicketDataSourceImpl implements TicketDataSource {
  final Dio client;
  final AuthService authService;

  TicketDataSourceImpl({
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

  String _getApiUrl() => '${AppConfig.apiUrl}/ticket';

  @override
  Future<List<Ticket>> getTicketsByUser() async {
    try {
      final headers = await _getHeaders();

      print('🎫 Récupération des tickets utilisateur');

      final response = await client.get(
        '${_getApiUrl()}/user',
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data ?? [];
        print('✅ ${jsonList.length} tickets trouvés');
        return jsonList
            .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur lors de la récupération des tickets',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur getTicketsByUser: ${e.message}');
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
  Future<Ticket> createTicket(Ticket ticket) async {
    try {
      final headers = await _getHeaders();

      print('🎫 Création d\'un ticket');
      print('Type: ${ticket.typeTransaction}');
      print('Ticket data: ${ticket.toJson()}');

      final response = await client.post(
        "${_getApiUrl()}/create",
        data: ticket.toJson(),
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Ticket créé avec succès');
        return Ticket.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur lors de la création',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur createTicket: ${e.message}');
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
  Future<Ticket> confirmReservation(int ticketId, String modePaiement) async {
    try {
      final headers = await _getHeaders();

      print('🎫 Confirmation de réservation ticket $ticketId');

      final response = await client.post(
        '${_getApiUrl()}/$ticketId/confirm',
        data: {
          'modePaiement': modePaiement,
        },
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Réservation confirmée');
        return Ticket.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur lors de la confirmation',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur confirmReservation: ${e.message}');
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
  Future<Ticket> cancelTicket(int ticketId) async {
    try {
      final headers = await _getHeaders();

      print('🎫 Annulation du ticket $ticketId');

      final response = await client.post(
        '${_getApiUrl()}/$ticketId/cancel',
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Ticket annulé');
        return Ticket.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur lors de l\'annulation',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur cancelTicket: ${e.message}');
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
  Future<List<Ticket>> getTicketsByStatus(String status) async {
    try {
      final headers = await _getHeaders();

      print('🎫 Récupération des tickets avec statut: $status');

      final response = await client.get(
        '${_getApiUrl()}/status/$status',
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data ?? [];
        print('✅ ${jsonList.length} tickets trouvés');
        return jsonList
            .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await authService.removeTokens();
      }
      throw ServerException(
        message: e.message ?? 'Erreur',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw NetworkException(message: 'Erreur de réseau: ${e.toString()}');
    }
  }
}