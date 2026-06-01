import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- 1. Adicione isso

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // <-- 2. Adicione isso

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> registerOrganizer(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // ==========================================
      // 3. NOVO: Salva os dados no Firestore também!
      // ==========================================
      if (result.user != null) {
        await _firestore.collection('organizers').doc(result.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return result.user;
    } catch (e) {
      throw Exception('Erro ao registrar: $e');
    }
  }

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

  Future<User?> loginGuestAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      throw Exception('Erro ao conectar como convidado: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }
}