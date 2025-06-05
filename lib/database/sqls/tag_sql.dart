class IngredientSql {
  static String createtagTable() {
    return '''
      CREATE TABLE tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
      )
    ''';
  }
}
