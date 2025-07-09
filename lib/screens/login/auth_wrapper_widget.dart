import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/login_service.dart';
import 'login_form_widget.dart';

class AuthWrapperWidget extends StatelessWidget {
  final Widget homeScreen;

  const AuthWrapperWidget({super.key, required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    final LoginService loginService = LoginService();

    return StreamBuilder<User?>(
      stream: loginService.user,
      builder: (context, snapshot) {
        // Verificando o estado da conexão
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se há erro
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao verificar autenticação',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verifique sua conexão com a internet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Força um rebuild do widget
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  AuthWrapperWidget(homeScreen: homeScreen),
                        ),
                      );
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        // Se o usuário está logado, mostra a tela principal
        if (snapshot.hasData && snapshot.data != null) {
          return homeScreen;
        }

        // Se não está logado, mostra a tela de login
        return LoginFormWidget(
          onLoginSuccess: () {
            // o StreamBuilder vai detectar automaticamente a mudança de estado
          },
        );
      },
    );
  }
}
