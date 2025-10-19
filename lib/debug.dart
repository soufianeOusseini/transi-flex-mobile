import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transi_flex_mobile/authentification/service/auth_service.dart';
import 'package:transi_flex_mobile/injection.dart';

/// Page de debug pour vérifier l'état du token
class DebugTokenPage extends StatefulWidget {
  const DebugTokenPage({Key? key}) : super(key: key);

  @override
  State<DebugTokenPage> createState() => _DebugTokenPageState();
}

class _DebugTokenPageState extends State<DebugTokenPage> {
  String _tokenStatus = 'Chargement...';
  String _tokenPreview = '';
  String _refreshTokenPreview = '';
  bool _isValid = false;
  bool _isExpired = true;
  Map<String, dynamic>? _tokenPayload;

  @override
  void initState() {
    super.initState();
    _loadTokenInfo();
  }

  Future<void> _loadTokenInfo() async {
    try {
      final authService = sl<AuthService>();
      final prefs = sl<SharedPreferences>();

      // Récupérer le token
      final token = await authService.getToken();
      final refreshToken = await authService.getRefreshToken();

      // Vérifier sa validité
      final isValid = await authService.hasValidToken();
      final isExpired = await authService.isTokenExpired();

      // Récupérer le payload
      final payload = await authService.getTokenPayload();

      // Vérifier SharedPreferences directement
      final tokenFromPrefs = prefs.getString('auth_token');
      final refreshFromPrefs = prefs.getString('refresh_token');
      final userData = prefs.getString('user_data');

      setState(() {
        _tokenStatus = token != null ? 'Token trouvé ✅' : 'Aucun token ❌';
        _tokenPreview = token != null ? '${token.substring(0, 50)}...' : 'N/A';
        _refreshTokenPreview = refreshToken != null ? '${refreshToken.substring(0, 30)}...' : 'N/A';
        _isValid = isValid;
        _isExpired = isExpired;
        _tokenPayload = payload;
      });

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 DEBUG TOKEN COMPLET');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📦 Via AuthService:');
      print('  • Token: ${token != null ? "Présent (${token.length} chars)" : "Absent"}');
      print('  • Refresh: ${refreshToken != null ? "Présent" : "Absent"}');
      print('  • Valide: $isValid');
      print('  • Expiré: $isExpired');
      print('');
      print('📦 Via SharedPreferences direct:');
      print('  • auth_token: ${tokenFromPrefs != null ? "Présent" : "Absent"}');
      print('  • refresh_token: ${refreshFromPrefs != null ? "Présent" : "Absent"}');
      print('  • user_data: ${userData != null ? "Présent" : "Absent"}');
      print('');
      print('📄 Payload JWT:');
      print('  $payload');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      setState(() {
        _tokenStatus = 'Erreur: $e';
      });
      print('❌ Erreur debug: $e');
    }
  }

  Future<void> _clearAllTokens() async {
    try {
      final authService = sl<AuthService>();
      await authService.removeTokens();

      setState(() {
        _tokenStatus = 'Tokens supprimés ✅';
        _tokenPreview = '';
        _refreshTokenPreview = '';
      });

      print('🗑️ Tous les tokens supprimés');
    } catch (e) {
      print('❌ Erreur suppression: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Token'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTokenInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'État du Token',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_tokenStatus),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isValid ? Icons.check_circle : Icons.error,
                          color: _isValid ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(_isValid ? 'Valide' : 'Invalide'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isExpired ? Icons.warning : Icons.check_circle,
                          color: _isExpired ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(_isExpired ? 'Expiré' : 'Non expiré'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Token Preview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Access Token',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _tokenPreview.isEmpty ? 'Aucun token' : _tokenPreview,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Refresh Token Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refresh Token',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _refreshTokenPreview.isEmpty
                          ? 'Aucun refresh token'
                          : _refreshTokenPreview,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payload Card
            if (_tokenPayload != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payload JWT',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ..._tokenPayload!.entries.map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                '${entry.key}:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text('${entry.value}'),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadTokenInfo,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Rafraîchir'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearAllTokens,
                    icon: const Icon(Icons.delete),
                    label: const Text('Effacer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}