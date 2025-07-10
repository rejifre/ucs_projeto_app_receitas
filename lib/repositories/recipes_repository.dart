import 'package:logger/logger.dart';
import 'package:ucs_projeto_app_receitas/services/category_service.dart';
import '../models/recipe_model.dart';
import '../services/instruction_service.dart';
import '../services/ingredient_service.dart';
import '../services/recipe_generator_service.dart';
import '../services/recipe_service.dart';
import '../services/recipe_tag_service.dart';
import '../services/tag_service.dart';

class RecipesRepository {
  final RecipeService _recipeService = RecipeService();
  final IngredientService _ingredientService = IngredientService();
  final InstructionService _instructionService = InstructionService();
  final TagService _tagsService = TagService();
  final RecipeTagService _recipeTagService = RecipeTagService();
  final CategoryService _categoryService = CategoryService();

  final RecipeGeneratorService _recipeGeneratorService =
      RecipeGeneratorService();
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
    await _recipeService.insert(recipe);

    for (var ingr in recipe.ingredients) {
      await _ingredientService.insert(ingr);
    }

    for (var step in recipe.steps) {
      await _instructionService.insert(step);
    }

    for (var tag in recipe.tags) {
      await _recipeTagService.associateTagWithRecipe(recipe.id, tag.id);
    }

    for (var category in recipe.categories) {
      await _categoryService.associateCategoryWithRecipe(
        recipe.id,
        category.id,
      );
    }

    logger.i('added recipe');
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _recipeService.update(recipe);
    await _ingredientService.update(recipe.id, recipe.ingredients);
    await _instructionService.update(recipe.id, recipe.steps);
    await _tagsService.updateRecipeTags(
      recipe.id,
      recipe.tags.map((tag) => tag.id).toList(),
    );
    await _categoryService.updateRecipeCategories(
      recipe.id,
      recipe.categories.map((category) => category.id).toList(),
    );

    logger.i('update recipe');
  }

  Future<void> deleteRecipe(String recipeId) async {
    if (recipeId.isEmpty) {
      throw Exception('Recipe ID cannot be empty');
    }
    final recipe = await getRecipeById(recipeId);
    if (recipe == null) {
      throw Exception('Recipe not found');
    }

    await _recipeService.delete(recipeId);
    await _ingredientService.deleteByRecipeId(recipeId);
    await _instructionService.deleteByRecipeId(recipeId);
    await _recipeTagService.removeTagsByRecipeId(recipeId);
    await _categoryService.removeCategoriesByRecipeId(recipeId);

    for (var tag in recipe.tags) {
      await _tagsService.dissociateTagFromRecipe(recipeId, tag.id);
    }

    for (var category in recipe.categories) {
      await _categoryService.dissociateCategoryFromRecipe(
        recipeId,
        category.id,
      );
    }

    logger.i('Delete Recipe');
  }

  Future<void> _getRecipeInfo(Recipe recipe) async {
    final ingredients = await _ingredientService.getAllByRecipeId(recipe.id);
    recipe.ingredients = [...ingredients];

    final steps = await _instructionService.getAllByRecipeId(recipe.id);
    recipe.steps = [...steps];

    final tags = await _tagsService.getTagsByRecipeId(recipe.id);
    recipe.tags = [...tags];

    final categories = await _categoryService.getCategoriesByRecipeId(
      recipe.id,
    );
    recipe.categories = [...categories];
  }

  Future<List<Recipe>> getAllRecipes() async {
    final recipes = await _recipeService.getAll();

    for (var recipe in recipes) {
      await _getRecipeInfo(recipe);
    }

    logger.i('Get All Recipes');
    logger.i(recipes);
    return recipes;
  }

  Future<Recipe?> getRecipeById(String id) async {
    final data = await _recipeService.getById(id);
    if (data != null) {
      await _getRecipeInfo(data);
      return data;
    }

    return null;
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final recipes = await _recipeService.searchByName(query);
    for (var recipe in recipes) {
      await _getRecipeInfo(recipe);
    }

    logger.i('Search Recipes');
    logger.i(recipes);
    return recipes;
  }

  Future<Recipe> generateRecipe() async {
    // Assuming getRecipe() returns a List<Category>. If not, adjust accordingly.
    final recipe = await _recipeGeneratorService.getRecipe();
    return recipe ??
        Recipe(
          id: '',
          description: 'No description available',
          ingredients: [],
          steps: [],
          title: 'No Title Available',
          score: 0,
          date: '',
          preparationTime: '',
        );
  }
}
