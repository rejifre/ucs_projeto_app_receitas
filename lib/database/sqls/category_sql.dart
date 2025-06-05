class CategorySql {
  static String createCategoryTable() {
    return '''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''';
  }
}
