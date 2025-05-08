import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/recipes_service.dart';

class RecipesProvider with ChangeNotifier {
  final RecipesService _service = RecipesService();
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  RecipesProvider() {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    _recipes = await _service.getAllRecipes();
    notifyListeners();
  }

  Future<void> deleteRecipe(String id) async {
    await _service.deleteRecipe(id);
    await loadRecipes(); // Atualiza a lista
  }

  void addOrUpdateRecipe(Recipe recipe) async {
    if (_recipes.any((r) => r.id == recipe.id)) {
      // Se a receita já existe, atualiza-a
      await _service.updateRecipe(recipe);
    } else {
      // Caso contrário, adiciona uma nova receita
      await _service.addRecipe(recipe);
    }
    await loadRecipes();
  }
}
