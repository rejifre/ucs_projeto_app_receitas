import 'package:flutter/material.dart';
import '../routes/routes.dart';
import '../ui/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToAuth();
  }

  _navigateToAuth() async {
    // Aguarda um pouco para mostrar a splash screen
    await Future.delayed(const Duration(seconds: 1, milliseconds: 0));

    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 60,
                color: AppColors.buttonMainColor,
              ),
            ),
            const SizedBox(height: 32),

            // Nome do app
            const Text(
              "App Receitas",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Subtítulo
            const Text(
              "Suas receitas favoritas em um só lugar",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16.0,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 48),

            // Indicador de carregamento
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
