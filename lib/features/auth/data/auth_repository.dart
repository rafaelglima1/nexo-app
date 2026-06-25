import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/api_client.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient;
  final ApiClient _apiClient;

  AuthRepository(this._supabaseClient, this._apiClient);

  User? get currentUser => _supabaseClient.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;

  String? get accessToken => _apiClient.isAuthenticated ? null : null;

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _apiClient.post('/api/auth/register', body: {
      'email': email,
      'password': password,
      'name': name,
    });

    _apiClient.setTokens(
      accessToken: response['accessToken'],
      refreshToken: response['refreshToken'],
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });

    _apiClient.setTokens(
      accessToken: response['accessToken'],
      refreshToken: response['refreshToken'],
    );
  }

  Future<void> signInWithGoogle() async {
    await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.nexo://login-callback/',
    );
  }

  Future<void> signInWithApple() async {
    await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.nexo://login-callback/',
    );
  }

  Future<void> signOut() async {
    _apiClient.clearTokens();
    await _supabaseClient.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  Future<Map<String, dynamic>?> getProfile() async {
    if (!_apiClient.isAuthenticated) return null;
    try {
      return await _apiClient.get('/api/users/me');
    } catch (e) {
      return null;
    }
  }
}
