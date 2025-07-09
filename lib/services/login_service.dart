import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para monitorar mudanças no estado de autenticação
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Método para login
  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseAuthErrorMessage(e);
    } catch (e) {
      throw 'Erro inesperado: $e';
    }
  }

  // Método para cadastro
  Future<UserCredential?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Atualizar o displayName do usuário
      await result.user?.updateDisplayName(name);

      // Salvar dados adicionais no Firestore
      await _firestore.collection('users').doc(result.user?.uid).set({
        'name': name,
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return result;
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseAuthErrorMessage(e);
    } catch (e) {
      throw 'Erro inesperado: $e';
    }
  }

  // Método para deletar conta
  Future<String?> deleteAccount({required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _auth.currentUser!.email!,
        password: password,
      );
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseAuthErrorMessage(e);
    }
  }

  // Método para logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Método para redefinir senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseAuthErrorMessage(e);
    } catch (e) {
      throw 'Erro inesperado: $e';
    }
  }

  // Obter usuário atual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Verificar se o usuário está logado
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Traduzir mensagens de erro do Firebase
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado. Verifique o e-mail digitado.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso por outra conta.';
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'E-mail inválido. Verifique o formato do e-mail.';
      case 'operation-not-allowed':
        return 'Operação não permitida. Contate o suporte.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      default:
        return 'Erro: ${e.message}';
    }
  }
}
