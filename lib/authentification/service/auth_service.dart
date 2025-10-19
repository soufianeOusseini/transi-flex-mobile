import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Service centralisé pour gérer l'authentification
abstract class AuthService {
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<void> removeTokens();
  Future<bool> hasValidToken();
  Future<bool> isTokenExpired();
  Future<Map<String, dynamic>?> getTokenPayload();
  Future<String?> getUserId();
  Future<String?> getUserRole();
}

class AuthServiceImpl implements AuthService {
  final SharedPreferences sharedPreferences;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  AuthServiceImpl({required this.sharedPreferences});

  @override
  Future<String?> getToken() async {
    try {
      final token = sharedPreferences.getString(_tokenKey);

      print('🔍 Récupération token: ${token != null ? "✅ Trouvé (${token.substring(0, 20)}...)" : "❌ Non trouvé"}');

      if (token == null || token.isEmpty) {
        print('⚠️ Token vide ou null');
        return null;
      }

      // Vérifier si le token est expiré
      final isExpired = await isTokenExpired();
      if (isExpired) {
        print('⚠️ Token expiré');
        return null;
      }

      print('✅ Token valide récupéré');
      return token;
    } catch (e) {
      print('❌ Erreur récupération token: $e');
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final refreshToken = sharedPreferences.getString(_refreshTokenKey);
      print('🔄 Refresh token: ${refreshToken != null ? "Trouvé" : "Non trouvé"}');
      return refreshToken;
    } catch (e) {
      print('❌ Erreur récupération refresh token: $e');
      return null;
    }
  }

  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    try {
      // Sauvegarder l'access token
      await sharedPreferences.setString(_tokenKey, accessToken);
      print('✅ Access token sauvegardé: ${accessToken.substring(0, 20)}...');

      // Sauvegarder le refresh token si fourni
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await sharedPreferences.setString(_refreshTokenKey, refreshToken);
        print('✅ Refresh token sauvegardé');
      }

      // Vérifier immédiatement que le token est bien sauvegardé
      final savedToken = sharedPreferences.getString(_tokenKey);
      if (savedToken == null) {
        print('❌ ERREUR: Token non sauvegardé dans SharedPreferences !');
      } else {
        print('✅ Vérification: Token bien présent dans SharedPreferences');
      }
    } catch (e) {
      print('❌ Erreur sauvegarde tokens: $e');
      rethrow; // Propager l'erreur pour la gérer en amont
    }
  }

  @override
  Future<void> removeTokens() async {
    try {
      await sharedPreferences.remove(_tokenKey);
      await sharedPreferences.remove(_refreshTokenKey);
      await sharedPreferences.remove(_userDataKey);
      print('🗑️ Tokens supprimés avec succès');
    } catch (e) {
      print('❌ Erreur suppression tokens: $e');
    }
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> isTokenExpired() async {
    try {
      final token = sharedPreferences.getString(_tokenKey);

      if (token == null || token.isEmpty) {
        print('⚠️ Pas de token à vérifier');
        return true;
      }

      // Utiliser jwt_decoder pour vérifier l'expiration
      final isExpired = JwtDecoder.isExpired(token);
      print('🕐 Token expiré: ${isExpired ? "OUI" : "NON"}');

      return isExpired;
    } catch (e) {
      print('❌ Erreur vérification expiration: $e');
      return true; // En cas d'erreur, considérer comme expiré
    }
  }

  @override
  Future<Map<String, dynamic>?> getTokenPayload() async {
    try {
      final token = sharedPreferences.getString(_tokenKey);
      if (token == null || token.isEmpty) return null;

      final payload = JwtDecoder.decode(token);
      print('📦 Payload décodé: ${payload.keys}');
      return payload;
    } catch (e) {
      print('❌ Erreur décodage token: $e');
      return null;
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      final payload = await getTokenPayload();
      final userId = payload?['sub'] ?? payload?['userId'] ?? payload?['id'];
      print('👤 User ID: $userId');
      return userId;
    } catch (e) {
      print('❌ Erreur récupération userId: $e');
      return null;
    }
  }

  @override
  Future<String?> getUserRole() async {
    try {
      final payload = await getTokenPayload();
      final role = payload?['role'] ?? payload?['authorities']?.first;
      print('🎭 User role: $role');
      return role;
    } catch (e) {
      print('❌ Erreur récupération role: $e');
      return null;
    }
  }
}