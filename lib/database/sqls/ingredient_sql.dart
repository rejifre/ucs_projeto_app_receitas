class IngredientSql {
  static String createIngredientTable() {
    return '''
      CREATE TABLE ingredient (
        id TEXT PRIMARY KEY,
        recipe_id TEXT,
        name TEXT NOT NULL,
        quantity TEXT,
        FOREIGN KEY (recipe_id) REFERENCES recipe (id) ON DELETE CASCADE
      )
    ''';
  }
}
