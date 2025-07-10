import '../models/ingredient_model.dart';
import '/database/database_helper.dart';

class IngredientService {
  static final DatabaseHelper _db = DatabaseHelper();

  static const String table = 'ingredients';

  Future<int> insert(Ingredient ingredient) async {
    return await _db.insert(table, ingredient.toMap());
  }

  // Método para inserção com substituição em caso de conflito (usado na restauração)
  Future<int> insertOrReplace(Ingredient ingredient) async {
    return await _db.insertOrReplace(table, ingredient.toMap());
  }

  Future<void> update(String recipeId, List<Ingredient> ingredients) async {
    deleteByRecipeId(recipeId);

    for (var ingredient in ingredients) {
      await _db.insert(table, ingredient.toMap());
    }
  }

  Future<int> delete(String ingredientId) async {
    return await _db.delete(table, 'id = ?', [ingredientId]);
  }

  Future<int> deleteByRecipeId(String recipeId) async {
    return await _db.delete(table, 'recipe_id = ?', [recipeId]);
  }

  Future<Ingredient?> getById(String ingredientId) async {
    final ingredient = await _db.getById(table, ingredientId);
    if (ingredient != null && ingredient.isNotEmpty) {
      return Ingredient.fromMap(ingredient);
    }
    return null;
  }

  Future<List<Ingredient>> getAllByRecipeId(String recipeId) async {
    List<Map<String, dynamic>> ingredientsDB = await _db.getAll(
      table,
      condition: 'recipe_id = ?',
      conditionArgs: [recipeId],
    );

    List<Ingredient> ingredients = [];

    for (var ingr in ingredientsDB) {
      Ingredient ingredient = Ingredient.fromMap(ingr);
      ingredients.add(ingredient);
    }

    return ingredients;
  }

  Future<List<Ingredient>> getAll() async {
    List<Map<String, dynamic>> ingredientsDB = await _db.getAll(table);
    List<Ingredient> ingredients = [];

    for (var item in ingredientsDB) {
      Ingredient ingredient = Ingredient.fromMap(item);
      ingredients.add(ingredient);
    }

    return ingredients;
  }

  Future<int> deleteAll() async {
    return await _db.deleteAll(IngredientService.table);
  }
}
