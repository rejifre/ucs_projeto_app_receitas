import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/categories_provider.dart';
import 'routes/routes.dart';
import 'screens/categories/categories_screen_widget.dart';
import 'screens/categories/edit_category_screen.dart';
import 'screens/recipes/edit_recipe_screen.dart';
import 'screens/home_screen.dart';
import 'screens/recipes/recipe_detail_screen.dart';
import 'providers/recipes_provider.dart';
import 'screens/search_screen.dart';
import 'screens/splash_screen.dart';
import 'ui/app_theme.dart';

void main() {
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
        routes: {
          Routes.initial: (context) => const SplashScreen(),
          Routes.home: (context) => const HomeScreen(),
          Routes.recipe: (context) => const RecipeDetailScreen(),
          Routes.editRecipe: (context) => EditRecipeScreen(),
          Routes.categoriesScreen: (context) => const CategoriesScreenWidget(),
          Routes.editCategory: (context) => const EditCategoryScreen(),
          Routes.search: (context) => const SearchScreen(),
        },
      ),
    );
  }
}
