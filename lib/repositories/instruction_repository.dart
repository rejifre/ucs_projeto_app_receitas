import '../models/instruction_model.dart';
import '/database/database_helper.dart';

class InstructionRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  static const String table = 'instruction';

  Future<int> insert(Instruction instruction) async {
    return await _db.insert(table, instruction.toMap());
  }

  Future<void> update(String recipeId, List<Instruction> instructions) async {
    deleteByRecipeId(recipeId);

    for (var instruction in instructions) {
      await _db.insert(table, instruction.toMap());
    }
  }

  Future<int> delete(String id) async {
    return await _db.delete(table, 'id = ?', [id]);
  }

  Future<int> deleteByRecipeId(String recipeId) async {
    return await _db.delete(table, 'recipe_id = ?', [recipeId]);
  }

  Future<Instruction?> getById(String id) async {
    final instruction = await _db.getById(table, id);

    if (instruction != null && instruction.isNotEmpty) {
      return Instruction.fromMap(instruction);
    }
    return null;
  }

  Future<List<Instruction>> getAll(String recipeId) async {
    List<Map<String, dynamic>> instructionsDB = await _db.getAll(
      table,
      condition: 'recipe_id = ?',
      conditionArgs: [recipeId],
    );

    List<Instruction> steps = [];

    for (var inst in instructionsDB) {
      Instruction instruction = Instruction.fromMap(inst);
      steps.add(instruction);
    }

    return steps;
  }
}
