class RecipeSql {
  static String createRecipeTable() {
    return '''
      CREATE TABLE recipe(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        score REAL,
        date TEXT,
        preparationTime TEXT
      )
    ''';
  }
}
