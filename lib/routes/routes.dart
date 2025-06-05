import 'package:flutter/material.dart';

class Routes {
  static GlobalKey<NavigatorState> navigation = GlobalKey<NavigatorState>();

  static const String initial = '/';
  static const String home = '/home';
  static const String recipe = '/recipe';
  static const String editRecipe = '/edit';
  static const String categoriesScreen = '/categories';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String editCategory = '/editCategory';
}
