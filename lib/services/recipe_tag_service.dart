import '../database/database_helper.dart';

class RecipeTagService {
  static final DatabaseHelper _db = DatabaseHelper();

  static const String table = 'recipe_tags';
  static const String recipeId = 'recipe_id';
  static const String tagId = 'tag_id';

  /// Associa uma tag a uma receita
  Future<void> associateTagWithRecipe(
    String recipeIdValue,
    String tagIdValue,
  ) async {
    await _db.insert(table, {recipeId: recipeIdValue, tagId: tagIdValue});
  }

  /// Remove todas as associações de tags de uma receita
  Future<void> removeTagsByRecipeId(String recipeIdValue) async {
    await _db.delete(table, '$recipeId = ?', [recipeIdValue]);
  }

  /// Remove uma associação específica de tag e receita
  Future<void> dissociateTagFromRecipe(
    String recipeIdValue,
    String tagIdValue,
  ) async {
    await _db.delete(table, '$recipeId = ? AND $tagId = ?', [
      recipeIdValue,
      tagIdValue,
    ]);
  }

  /// Busca todas as tags de uma receita (retorna lista de tag_id)
  Future<List<String>> getTagIdsByRecipeId(String recipeIdValue) async {
    final result = await _db.rawQuery(
      'SELECT $tagId FROM $table WHERE $recipeId = ?',
      [recipeIdValue],
    );
    return result.map((row) => row[tagId] as String).toList();
  }

  /// Atualiza as associações de tags de uma receita
  Future<void> updateRecipeTags(
    String recipeIdValue,
    List<String> tagIds,
  ) async {
    await removeTagsByRecipeId(recipeIdValue);
    for (final tagIdValue in tagIds) {
      await associateTagWithRecipe(recipeIdValue, tagIdValue);
    }
  }
}
