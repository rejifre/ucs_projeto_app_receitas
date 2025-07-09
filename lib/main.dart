import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/categories_provider.dart';
import 'routes/routes.dart';
import 'providers/recipes_provider.dart';
import 'ui/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecipesProvider()),
        ChangeNotifierProvider(create: (context) => CategoriesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecipesProvider(),
      child: MaterialApp(
        title: 'App Receitas',
        initialRoute: Routes.initial,
        navigatorKey: Routes.navigation,
        theme: AppTheme.appTheme,
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}
