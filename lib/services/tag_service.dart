import '../database/database_helper.dart';
import '../models/recipe_model.dart';
import '../models/tag_model.dart';

class TagService {
  static final DatabaseHelper _db = DatabaseHelper();

  static const String table = 'tags';
  static const String tableRecipeTags = 'recipe_tags';
  static const String recipeId = 'recipe_id';
  static const String tagId = 'tag_id';

  Future<int> insert(Tag tag) async {
    return await _db.insert(TagService.table, tag.toMap());
  }

  // Método para inserção com substituição em caso de conflito (usado na restauração)
  Future<int> insertOrReplace(Tag tag) async {
    return await _db.insertOrReplace(TagService.table, tag.toMap());
  }

  Future<int> update(Tag tag) async {
    return await _db.update(TagService.table, tag.toMap(), 'id = ?', [tag.id]);
  }

  Future<int> delete(String id) async {
    // Verifica se a tag está associada a alguma receita
    final associations = await _db.rawQuery(
      'SELECT 1 FROM ${TagService.tableRecipeTags} WHERE ${TagService.tagId} = ? LIMIT 1',
      [id],
    );
    if (associations.isNotEmpty) {
      throw Exception(
        'Não é possível deletar: tag ainda associada a uma receita.',
      );
    }
    return await _db.delete(TagService.table, 'id = ?', [id]);
  }

  Future<Tag?> getById(String id) async {
    final tag = await _db.getById(TagService.table, id);
    if (tag != null && tag.isNotEmpty) {
      return Tag.fromMap(tag);
    }
    return null;
  }

  Future<List<Tag>> getAll() async {
    List<Map<String, dynamic>> tagsDB = await _db.getAll(TagService.table);
    return tagsDB.map((tag) => Tag.fromMap(tag)).toList();
  }

  Future<int> associateTagWithRecipe(int recipeId, int tagId) async {
    final result = await _db.insert(TagService.tableRecipeTags, {
      TagService.recipeId: recipeId,
      TagService.tagId: tagId,
    });
    if (result == 0) {
      throw Exception('Failed to associate tag with recipe');
    }
    return result;
  }

  Future<int> dissociateTagFromRecipe(int recipeId, int tagId) async {
    final result = await _db.delete(
      TagService.tableRecipeTags,
      '${TagService.recipeId} = ? AND ${TagService.tagId} = ?',
      [recipeId, tagId],
    );
    if (result == 0) {
      throw Exception('Failed to dissociate tag from recipe');
    }
    return result;
  }

  Future<List<Tag>> getTagsByRecipeId(int recipeId) async {
    final List<Map<String, dynamic>> result = await _db.rawQuery(
      '''
      SELECT t.* FROM ${TagService.table} t
      INNER JOIN ${TagService.tableRecipeTags} rt ON t.id = rt.tag_id
      WHERE rt.${TagService.recipeId} = ?
    ''',
      [recipeId],
    );

    return result.map((tagMap) => Tag.fromMap(tagMap)).toList();
  }

  // Para buscar receitas por uma única tag
  Future<List<Recipe>> getRecipesByTagId(int tagId) async {
    final recipes = await _db.rawQuery(
      '''
    SELECT r.* FROM recipes r
    JOIN ${TagService.tableRecipeTags} rt ON r.id = rt.recipe_id
    WHERE rt.tag_id = ?
    ''',
      [tagId],
    );
    return recipes.map((recipe) => Recipe.fromMap(recipe)).toList();
  }

  // Para buscar por várias tags
  Future<List<Recipe>> getRecipesByTagIds(List<int> tagIds) async {
    final placeholders = List.filled(tagIds.length, '?').join(',');
    final recipes = await _db.rawQuery('''
    SELECT DISTINCT r.* FROM recipes r
    JOIN ${TagService.tableRecipeTags} rt ON r.id = rt.recipe_id
    WHERE rt.tag_id IN ($placeholders)
    ''', tagIds);
    return recipes.map((recipe) => Recipe.fromMap(recipe)).toList();
  }

  Future<List<Tag>> searchByName(String name) async {
    final tagsDB = await _db.searchByName(TagService.table, 'name', name);
    return tagsDB.map((item) => Tag.fromMap(item)).toList();
  }

  Future<int> deleteAll() async {
    return await _db.deleteAll(TagService.table);
  }
}
