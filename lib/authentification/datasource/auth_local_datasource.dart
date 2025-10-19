import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/exceptions.dart';
import '../model/user.dart';

abstract class AuthLocalDataSource {
  Future<User?> getCachedUser();
  Future<void> cacheUser(User user);
  Future<void> clearCachedUser();
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<User?> getCachedUser() async {
    try {
      final userData = sharedPreferences.getString('user_data');
      if (userData != null) {
        final userJson = jsonDecode(userData);
        return User.fromJson(userJson);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la récupération des données utilisateur');
    }
  }

  @override
  Future<void> cacheUser(User user) async {
    try {
      await sharedPreferences.setString('user_data', jsonEncode(user.toJson()));
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la sauvegarde des données utilisateur');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await sharedPreferences.remove('user_data');
      await sharedPreferences.remove('auth_token');
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la suppression des données utilisateur');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return sharedPreferences.getString('auth_token');
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la récupération du token');
    }
  }
}