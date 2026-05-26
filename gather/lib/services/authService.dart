import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para escutar mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Retorna o usuário logado atual
  User? get currentUser => _auth.currentUser;

  // Login para o Organizador (Email e Senha)
  Future<User?> loginOrganizer(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  // Login Anônimo para o Convidado (Garante segurança no Firestore)
  Future<User?> loginGuestAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      throw Exception('Erro ao conectar como convidado: $e');
    }
  }

  // Sair do aplicativo (Logout)
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }
}