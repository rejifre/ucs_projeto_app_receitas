class IngredientSql {
  static String createtagTable() {
    return '''
      CREATE TABLE tag (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
      )
    ''';
  }
}
