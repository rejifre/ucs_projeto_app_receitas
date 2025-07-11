import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'sqls/category_sql.dart';
import 'sqls/ingredient_sql.dart';
import 'sqls/instruction_sql.dart';
import 'sqls/recipe_category_sql.dart';
import 'sqls/recipe_sql.dart';
import 'sqls/recipe_tag_sql.dart';
import 'sqls/tag_sql.dart';

class DatabaseHelper {
  static Database? _database;
  static final String _databaseName = "meubanco.db";
  static final int _databaseVersion = 1;

  // Acesso seguro à instância do banco
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _init();
    return _database!;
  }

  Future<Database> _init() async {
    String pathDB = join(await getDatabasesPath(), _databaseName);
    final db = await openDatabase(
      pathDB,
      version: _databaseVersion,
      onCreate: createDB,
      onUpgrade: updateDB,
    );
    return db;
  }

  Future updateDB(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 2) {}
  }

  Future createDB(Database db, int version) async {
    await db.execute(RecipeSql.createRecipeTable());
    await db.execute(IngredientSql.createIngredientTable());
    await db.execute(InstructionSql.createInstructionTable());
    await db.execute(CategorySql.createCategoryTable());
    await db.execute(TagSql.createTagTable());
    await db.execute(RecipeCategorySql.createRecipeCategoryTable());
    await db.execute(RecipeTagSql.createRecipeTagTable());
  }

  Future<int> insert(String table, Map<String, Object?> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  // Método que usa INSERT OR REPLACE para evitar conflitos de primary key
  Future<int> insertOrReplace(String table, Map<String, Object?> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String? condition,
    List<dynamic>? conditionArgs,
  ) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: condition,
      whereArgs: conditionArgs,
    );
  }

  Future<int> delete(
    String table,
    String condition,
    List<Object> conditionArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: condition, whereArgs: conditionArgs);
  }

  Future<List<Map<String, Object?>>> getAll(
    String table, {
    String? condition,
    List<Object>? conditionArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(table, where: condition, whereArgs: conditionArgs);
  }

  Future<Map<String, Object?>?> getById(String table, id) async {
    final db = await database;
    final result = await db.query(table, where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<List<Map<String, Object?>>> searchByName(
    String table,
    String nameColumn,
    String name,
  ) async {
    final db = await database;
    return await db.query(
      table,
      where: '$nameColumn LIKE ?',
      whereArgs: ['%$name%'],
    );
  }

  Future<int> deleteAll(String table) async {
    final db = await database;
    return await db.delete(table);
  }
}
