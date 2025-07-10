class RecipeCategorySql {
  static String createRecipeCategoryTable() {
    return '''
      CREATE TABLE recipe_categories (
        recipe_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        PRIMARY KEY (recipe_id, category_id),
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''';
  }
}
