import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:transi_flex_mobile/app_config.dart';
import 'package:transi_flex_mobile/authentification/service/auth_service.dart';
import '../../core/exceptions.dart';
import '../model/auth_request.dart';
import '../model/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> login(LoginRequest request);
  Future<User> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> refreshToken();
}

class AuthRemoteDataSourceImpl extends AuthRemoteDataSource {
  final http.Client client;
  final AuthService authService;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.authService,
  });

  @override
  Future<User> login(LoginRequest request) async {
    try {
      print('🔐 Tentative de connexion pour: ${request.username}');

      final response = await client.post(
        Uri.parse('${AppConfig.apiUrl}/authentication/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('📡 Réponse login: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('📦 Données reçues: ${jsonResponse.keys}');

        final accessToken = jsonResponse['accessToken'];
        final refreshToken = jsonResponse['refreshToken'];
        final user = User.fromJson(jsonResponse['user']);

        // ✅ CRITIQUE: Vérifier que les tokens existent
        if (accessToken == null || accessToken.isEmpty) {
          throw ServerException(
            message: 'Token d\'accès manquant dans la réponse',
            statusCode: 500,
          );
        }

        // ✅ Sauvegarder les tokens AVANT de retourner l'utilisateur
        print('💾 Sauvegarde des tokens...');
        await authService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // ✅ Vérifier immédiatement que le token est accessible
        final savedToken = await authService.getToken();
        if (savedToken == null) {
          throw ServerException(
            message: 'Échec de la sauvegarde du token',
            statusCode: 500,
          );
        }

        print('✅ Login réussi - Token sauvegardé et vérifié');
        return user;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw ServerException(
          message: errorResponse['message'] ?? 'Erreur de connexion',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      print('❌ Erreur login: $e');
      throw NetworkException(message: 'Erreur de réseau: ${e.toString()}');
    }
  }

  @override
  Future<User> register(RegisterRequest request) async {
    try {
      print('📝 Tentative d\'inscription pour: ${request.email}');

      final response = await client.post(
        Uri.parse('${AppConfig.apiUrl}/authentication/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('🔗 URL complète: ${AppConfig.apiUrl}/user/register');
      print('📡 Réponse register: ${response.statusCode}');
      print('📄 Body: ${response.body}'); // ✅ Debug: voir le body exact

      // ✅ Vérifier que le body n'est pas vide AVANT de le parser
      if (response.body.isEmpty) {
        throw ServerException(
          message: 'Réponse vide du serveur',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final accessToken = jsonResponse['accessToken'];
        final refreshToken = jsonResponse['refreshToken'];
        final user = User.fromJson(jsonResponse['user']);

        if (accessToken == null || accessToken.isEmpty) {
          throw ServerException(
            message: 'Token d\'accès manquant dans la réponse',
            statusCode: 500,
          );
        }

        print('💾 Sauvegarde des tokens...');
        await authService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Vérifier que le token est bien sauvegardé
        final savedToken = await authService.getToken();
        if (savedToken == null) {
          throw ServerException(
            message: 'Échec de la sauvegarde du token',
            statusCode: 500,
          );
        }

        print('✅ Inscription réussie - Token sauvegardé et vérifié');
        return user;
      } else {
        // ✅ Parser l'erreur de la même manière
        if (response.body.isEmpty) {
          throw ServerException(
            message: 'Erreur ${response.statusCode}: Pas de détails',
            statusCode: response.statusCode,
          );
        }

        final errorResponse = jsonDecode(response.body);
        throw ServerException(
          message: errorResponse['message'] ?? 'Erreur lors de l\'inscription',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      print('❌ Erreur register: $e');
      print('Stack trace: $e'); // ✅ Meilleur debug
      throw NetworkException(message: 'Erreur de réseau: ${e.toString()}');
    }
  }


  @override
  Future<void> logout() async {
    try {
      print('🚪 Déconnexion...');
      final token = await authService.getToken();

      if (token != null && token.isNotEmpty) {
        print('📡 Envoi requête logout au serveur...');
        try {
          await client.post(
            Uri.parse('${AppConfig.apiUrl}/authentication/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 30));
          print('✅ Logout serveur réussi');
        } catch (e) {
          print('⚠️ Erreur logout serveur (on continue quand même): $e');
        }
      }

      // ✅ Toujours nettoyer les tokens locaux
      await authService.removeTokens();
      print('✅ Tokens locaux supprimés');
    } catch (e) {
      print('❌ Erreur logout: $e');
      // Nettoyer quand même les tokens en cas d'erreur
      await authService.removeTokens();
      throw NetworkException(message: 'Erreur lors de la déconnexion');
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      print('🔄 Tentative de refresh du token...');
      final refreshTok = await authService.getRefreshToken();

      if (refreshTok == null || refreshTok.isEmpty) {
        print('❌ Pas de refresh token disponible');
        return false;
      }

      final response = await client.post(
        Uri.parse('${AppConfig.apiUrl}/authentication/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshTok}),
      ).timeout(const Duration(seconds: 30));

      print('📡 Réponse refresh: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final newAccessToken = jsonResponse['accessToken'];
        final newRefreshToken = jsonResponse['refreshToken'];

        if (newAccessToken == null || newAccessToken.isEmpty) {
          print('❌ Nouveau token manquant');
          return false;
        }

        await authService.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        print('✅ Token refresh avec succès');
        return true;
      }

      print('❌ Échec refresh token: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Erreur refresh token: $e');
      return false;
    }
  }
}