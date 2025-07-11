import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../repositories/recipes_repository.dart';

class RecipesProvider with ChangeNotifier {
  final RecipesRepository _service = RecipesRepository();
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

  Future<void> addOrUpdateRecipe(Recipe recipe) async {
    if (_recipes.any((r) => r.id == recipe.id)) {
      // Se a receita já existe, atualiza-a
      await _service.updateRecipe(recipe);
    } else {
      // Caso contrário, adiciona uma nova receita
      await _service.addRecipe(recipe);
    }
    await loadRecipes();
  }

  Future<void> searchRecipes([String? query]) async {
    if (query != null && query.isNotEmpty) {
      _recipes = await _service.searchRecipes(query);
    } else {
      _recipes = [];
    }
    notifyListeners();
  }
}
