import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/api_client.dart';
import '../data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  String? _errorMessage;
  bool _isLoading = false;
  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider(this._repository) {
    _init();
  }

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  User? get currentUser => _repository.currentUser;

  void _init() {
    if (_repository.currentUser != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }

    _authSubscription = _repository.authStateChanges.listen((state) {
      if (state.event == AuthChangeEvent.signedIn) {
        _status = AuthStatus.authenticated;
      } else if (state.event == AuthChangeEvent.signedOut) {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signUp(String email, String password, String name) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.signUpWithEmail(email: email, password: password, name: name);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro inesperado. Tente novamente.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.signInWithEmail(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro inesperado. Tente novamente.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.signInWithGoogle();
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao entrar com Google.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithApple() async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.signInWithApple();
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao entrar com Apple.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.resetPassword(email);
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro ao enviar email de recuperação.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    _setLoading(true);
    try {
      await _repository.deleteAccount();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao excluir conta.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
