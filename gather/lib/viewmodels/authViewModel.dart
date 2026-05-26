import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/authService.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthViewModel() {
    // Escuta as mudanças de login em tempo real
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<bool> loginOrganizer(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.loginOrganizer(email, password);
      _setLoading(false);
      return true; // Login com sucesso
    } catch (e) {
      _errorMessage = "Email ou senha incorretos.";
      _setLoading(false);
      return false; // Falha no login
    }
  }

  Future<bool> loginGuest() async {
    _setLoading(true);
    try {
      await _authService.loginGuestAnonymously();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Erro ao entrar no evento.";
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}