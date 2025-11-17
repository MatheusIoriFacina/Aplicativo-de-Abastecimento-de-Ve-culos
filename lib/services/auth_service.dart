import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Detecta usuário logado / deslogado
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // LOGIN
  Future<String?> login({required String email, required String senha}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    }
  }

  // CADASTRO
  Future<String?> register({required String email, required String senha}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    }
  }

  // LOGOUT
  Future logout() => _auth.signOut();

  // Tradução dos erros
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "E-mail inválido.";
      case 'user-not-found':
        return "Usuário não encontrado.";
      case 'wrong-password':
        return "Senha incorreta.";
      case 'email-already-in-use':
        return "Este e-mail já está cadastrado.";
      case 'weak-password':
        return "A senha deve ter pelo menos 6 caracteres.";
      default:
        return "Erro: ${e.message}";
    }
  }
}
