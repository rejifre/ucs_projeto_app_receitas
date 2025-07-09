import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login/auth_wrapper_widget.dart';
import '../screens/home/home_screen.dart';
import '../screens/categories/categories_screen_widget.dart';
import '../screens/categories/edit_category_screen.dart';
import '../screens/recipes/edit_recipe_screen.dart';
import '../screens/recipes/recipe_detail_screen.dart';
import '../screens/search_screen.dart';
import '../screens/login/login_form_widget.dart';
import '../screens/user_profile_screen.dart';

class Routes {
  static GlobalKey<NavigatorState> navigation = GlobalKey<NavigatorState>();

  static const String initial = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String recipe = '/recipe';
  static const String editRecipe = '/edit';
  static const String categoriesScreen = '/categories';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String editCategory = '/editCategory';
  static const String login = '/login';
  static const String userProfile = '/profile';

  // Método para gerar rotas dinamicamente
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapperWidget(homeScreen: HomeScreen()),
        );

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case recipe:
        return MaterialPageRoute(builder: (_) => const RecipeDetailScreen());

      case editRecipe:
        return MaterialPageRoute(builder: (_) => EditRecipeScreen());

      case categoriesScreen:
        return MaterialPageRoute(
          builder: (_) => const CategoriesScreenWidget(),
        );

      case editCategory:
        return MaterialPageRoute(builder: (_) => const EditCategoryScreen());

      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      case login:
        return MaterialPageRoute(
          builder:
              (_) => LoginFormWidget(
                onLoginSuccess: () {
                  navigation.currentState?.pushReplacementNamed(home);
                },
              ),
        );

      case userProfile:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('Rota não encontrada: ${settings.name}'),
                ),
              ),
        );
    }
  }
}
