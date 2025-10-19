import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transi_flex_mobile/authentification/model/user.dart';

abstract class UserService {
  Future<User?> getCurrentUser();
  Future<void> saveUser(User user);
  Future<void> clearUser();
  Future<int?> getCurrentUserId();
  Future<String?> getCurrentUserEmail();
  Future<String?> getCurrentUserName();
}

class UserServiceImpl implements UserService {
  final SharedPreferences sharedPreferences;

  UserServiceImpl({required this.sharedPreferences});

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userData = sharedPreferences.getString('user_data');
      if (userData != null) {
        final userJson = jsonDecode(userData);
        return User.fromJson(userJson);
      }
      print('⚠️ Aucun utilisateur stocké');
      return null;
    } catch (e) {
      print('❌ Erreur getCurrentUser: $e');
      return null;
    }
  }

  @override
  Future<void> saveUser(User user) async {
    try {
      await sharedPreferences.setString('user_data', jsonEncode(user.toJson()));
      print('✅ Utilisateur sauvegardé: ${user.email}');
    } catch (e) {
      print('❌ Erreur saveUser: $e');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await sharedPreferences.remove('user_data');
      print('🗑️ Utilisateur supprimé');
    } catch (e) {
      print('❌ Erreur clearUser: $e');
    }
  }

  @override
  Future<int?> getCurrentUserId() async {
    final user = await getCurrentUser();
    return user?.id;
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    final user = await getCurrentUser();
    return user?.email;
  }

  @override
  Future<String?> getCurrentUserName() async {
    final user = await getCurrentUser();
    return user?.firstName ?? user?.lastName ?? 'Utilisateur';
  }
}