import 'package:firebase_auth/firebase_auth.dart';
import '../services/login_service.dart';
import 'package:logger/logger.dart';

class LoginRepository {
  final LoginService _loginService = LoginService();
  final Logger logger = Logger();

  // Método para login
  Future<void> login({required String email, required String password}) async {
    var result = await _loginService.login(email: email, password: password);
    logger.i('Login result: $result');
  }

  // Método para cadastro
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    var result = await _loginService.register(
      email: email,
      password: password,
      name: name,
    );
    logger.i('Register result: $result');
  }

  // Método para logout
  Future<void> logout() async {
    await _loginService.logout();
  }

  // Método para redefinir senha
  Future<void> resetPassword(String email) async {
    await _loginService.resetPassword(email);
  }

  // Obter usuário atual
  User? getCurrentUser() {
    var user = _loginService.getCurrentUser();
    logger.i('Current user: ${user?.email}');
    return user;
  }

  // Verificar se o usuário está logado
  bool isLoggedIn() {
    return _loginService.isLoggedIn();
  }
}
