class RecipeTagSql {
  static String createRecipeTagTable() {
    return '''
      CREATE TABLE recipe_tags (
        recipe_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (recipe_id, tag_id),
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
      )
    ''';
  }
}
