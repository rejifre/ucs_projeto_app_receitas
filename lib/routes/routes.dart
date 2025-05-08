import 'package:flutter/material.dart';

class Routes {
  static GlobalKey<NavigatorState> navigation = GlobalKey<NavigatorState>();

  static const String initial = '/';
  static const String home = '/home';
  static const String recipe = '/recipe';
  static const String editRecipe = '/edit';
}
