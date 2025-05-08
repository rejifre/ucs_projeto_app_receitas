import 'package:logger/logger.dart';
import '../models/recipe_model.dart';
import '../repositories/instruction_repository.dart';
import '../repositories/ingredient_repository.dart';
import '../repositories/recipe_repository.dart';

class RecipesService {
  final RecipeRepository _recipeRepo = RecipeRepository();
  final IngredientRepository _ingredientRepo = IngredientRepository();
  final InstructionRepository _instructionRepo = InstructionRepository();
  final logger = Logger();

  Future<void> saveRecipe(Recipe recipe) async {
    final rec = await getRecipeById(recipe.id);

    if (rec == null) {
      await addRecipe(recipe);
    }
    {
      await updateRecipe(recipe);
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _recipeRepo.insert(recipe);

    for (var ingr in recipe.ingredients) {
      await _ingredientRepo.insert(ingr);
    }

    for (var step in recipe.steps) {
      await _instructionRepo.insert(step);
    }

    logger.i('added recipe');
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _recipeRepo.update(recipe);
    await _ingredientRepo.update(recipe.id, recipe.ingredients);
    await _instructionRepo.update(recipe.id, recipe.steps);

    logger.i('update recipe');
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _recipeRepo.delete(recipeId);
    await _ingredientRepo.deleteByRecipeId(recipeId);
    await _instructionRepo.deleteByRecipeId(recipeId);

    logger.i('Delete Recipe');
  }

  Future<void> _getRecipeInfo(Recipe recipe) async {
    final ingredients = await _ingredientRepo.getAll(recipe.id);
    recipe.ingredients = [...ingredients];

    final steps = await _instructionRepo.getAll(recipe.id);
    recipe.steps = [...steps];
  }

  Future<List<Recipe>> getAllRecipes() async {
    final recipes = await _recipeRepo.getAll();

    for (var recipe in recipes) {
      await _getRecipeInfo(recipe);
    }

    logger.i('Get All Recipes');
    logger.i(recipes);
    return recipes;
  }

  Future<Recipe?> getRecipeById(String id) async {
    final data = await _recipeRepo.getById(id);
    if (data != null) {
      await _getRecipeInfo(data);
      return data;
    }

    return null;
  }
}
