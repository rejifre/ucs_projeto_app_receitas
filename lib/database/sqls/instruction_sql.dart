class InstructionSql {
  static String createInstructionTable() {
    return '''
      CREATE TABLE instruction(
        id TEXT PRIMARY KEY, 
        recipe_id TEXT, 
        description TEXT, 
        step_order INTEGER, 
        FOREIGN KEY (recipe_id) REFERENCES recipe (id) ON DELETE CASCADE
      )
    ''';
  }
}
