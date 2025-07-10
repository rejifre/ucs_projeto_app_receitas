import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/login/auth_wrapper_widget.dart';
import '../screens/home/home_screen.dart';
import '../screens/categories/categories_screen_widget.dart';
import '../screens/categories/edit_category_screen.dart';
import '../screens/recipes/edit_recipe_screen.dart';
import '../screens/recipes/recipe_detail_screen.dart';
import '../screens/search_screen.dart';
import '../screens/login/login_form_widget.dart';
import '../screens/tags/edit_tag_screen.dart';
import '../screens/tags/tags_screen.dart';
import '../screens/user_profile_screen.dart';

class Routes {
  static GlobalKey<NavigatorState> navigation = GlobalKey<NavigatorState>();

  static const String initial = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String recipeDetail = '/recipeDetail';
  static const String editRecipe = '/edit';
  static const String categoriesScreen = '/categories';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String editCategory = '/editCategory';
  static const String login = '/login';
  static const String userProfile = '/profile';
  static const String settings = '/settings';
  static const String tags = '/tags';
  static const String editTag = '/editTag';

  // Método para gerar rotas dinamicamente
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case initial:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapperWidget(homeScreen: HomeScreen()),
        );

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case recipeDetail:
        final String? recipeId = routeSettings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipeId: recipeId),
        );

      case editRecipe:
        return MaterialPageRoute(
          builder: (_) => const EditRecipeScreen(),
          settings: routeSettings,
        );

      case categoriesScreen:
        return MaterialPageRoute(
          builder: (_) => const CategoriesScreenWidget(),
        );

      case editCategory:
        return MaterialPageRoute(
          builder: (_) => const EditCategoryScreen(),
          settings: routeSettings,
        );

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

      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case tags:
        return MaterialPageRoute(builder: (_) => const TagsScreen());

      case editTag:
        return MaterialPageRoute(
          builder: (_) => const EditTagScreen(),
          settings: routeSettings,
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('Rota não encontrada: ${routeSettings.name}'),
                ),
              ),
        );
    }
  }
}
