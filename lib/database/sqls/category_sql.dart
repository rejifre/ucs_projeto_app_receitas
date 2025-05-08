class IngredientSql {
  static String createCategoryTable() {
    return '''
      CREATE TABLE category (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
      )
    ''';
  }
}
