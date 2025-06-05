class TagSql {
  static String createTagTable() {
    return '''
      CREATE TABLE tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      );
    ''';
  }
}
