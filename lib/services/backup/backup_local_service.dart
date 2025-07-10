// ignore_for_file: public_member_api_docs, sort_constructors_first
// services/backup_restore_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart'; // Importa o file_picker
import 'package:logger/web.dart';
import 'package:ucs_projeto_app_receitas/services/backup/backup_helper.dart';
import 'package:ucs_projeto_app_receitas/services/category_service.dart';
import 'package:ucs_projeto_app_receitas/services/ingredient_service.dart';
import 'package:ucs_projeto_app_receitas/services/instruction_service.dart';
import 'package:ucs_projeto_app_receitas/services/recipe_service.dart';
import 'package:ucs_projeto_app_receitas/services/tag_service.dart';

import '../../models/category_model.dart';
import '../../models/ingredient_model.dart';
import '../../models/instruction_model.dart';
import '../../models/recipe_model.dart';
import '../../models/tag_model.dart';

class BackupLocalService {
  final RecipeService _recipeService = RecipeService();
  final IngredientService _ingredientService = IngredientService();
  final InstructionService _instructionService = InstructionService();
  final CategoryService _categoryService = CategoryService();
  final TagService _tagService = TagService();
  final Logger _logger = Logger();
  final BackupHelper _backupHelper = BackupHelper();

  // Backup para Arquivo Local (usando FilePicker para salvar)
  Future<bool> backupToFile() async {
    try {
      final recipes = await _recipeService.getAll();
      final categories = await _categoryService.getAll();
      final tags = await _tagService.getAll();

      // Coleta ingredientes e instruções para todas as receitas
      List<Ingredient> allIngredients = await _ingredientService.getAll();
      List<Instruction> allInstructions = await _instructionService.getAll();

      // Cria o objeto de backup completo
      final Map<String, dynamic> backupData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'data': {
          'recipes': recipes.map((recipe) => recipe.toMap()).toList(),
          'categories': categories.map((category) => category.toMap()).toList(),
          'tags': tags.map((tag) => tag.toMap()).toList(),
          'ingredients':
              allIngredients.map((ingredient) => ingredient.toMap()).toList(),
          'instructions':
              allInstructions
                  .map((instruction) => instruction.toMap())
                  .toList(),
        },
      };

      final String jsonString = jsonEncode(backupData);

      // Abre o seletor de arquivos para o usuário escolher o local de salvamento
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Selecione onde salvar o backup completo',
        fileName: 'backup_completo_receitas.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile == null) {
        // Usuário cancelou a seleção
        _logger.i('Seleção de arquivo de backup cancelada.');
        return false;
      }

      final file = File(outputFile);
      await file.writeAsString(jsonString);
      _logger.i('Backup para arquivo local concluído: $outputFile');
      return true;
    } catch (e) {
      _logger.e('Erro ao fazer backup para arquivo: $e');
      return false;
    }
  }

  // Método auxiliar para restaurar backup completo
  Future<void> restoreCompleteBackup(Map<String, dynamic> backupData) async {
    final data = backupData['data'] as Map<String, dynamic>;

    // Limpa todos os dados existentes
    await _backupHelper.clearAllData();

    // Restaura categorias primeiro
    if (data.containsKey('categories')) {
      final categoriesJson = data['categories'] as List<dynamic>;
      for (final categoryJson in categoriesJson) {
        final category = Category.fromMap(categoryJson);
        await _categoryService.insertOrReplace(category);
      }
      _logger.i(
        'Restauração de categorias concluída: ${categoriesJson.length} categorias restauradas.',
      );
    }

    // Restaura tags
    if (data.containsKey('tags')) {
      final tagsJson = data['tags'] as List<dynamic>;
      for (final tagJson in tagsJson) {
        final tag = Tag.fromMap(tagJson);
        await _tagService.insertOrReplace(tag);
      }
      _logger.i(
        'Restauração de tags concluída: ${tagsJson.length} tags restauradas.',
      );
    }

    // Restaura receitas
    if (data.containsKey('recipes')) {
      final recipesJson = data['recipes'] as List<dynamic>;
      for (final recipeJson in recipesJson) {
        final recipe = Recipe.fromMap(recipeJson);
        await _recipeService.insertOrReplace(recipe);
      }
      _logger.i(
        'Restauração de receitas concluída: ${recipesJson.length} receitas restauradas.',
      );
    }

    // Restaura ingredientes
    if (data.containsKey('ingredients')) {
      final ingredientsJson = data['ingredients'] as List<dynamic>;
      for (final ingredientJson in ingredientsJson) {
        final ingredient = Ingredient.fromMap(ingredientJson);
        await _ingredientService.insertOrReplace(ingredient);
      }
      _logger.i(
        'Restauração de ingredientes concluída: ${ingredientsJson.length} ingredientes restaurados.',
      );
    }

    // Restaura instruções
    if (data.containsKey('instructions')) {
      final instructionsJson = data['instructions'] as List<dynamic>;
      for (final instructionJson in instructionsJson) {
        final instruction = Instruction.fromMap(instructionJson);
        await _instructionService.insertOrReplace(instruction);
      }
      _logger.i(
        'Restauração de instruções concluída: ${instructionsJson.length} instruções restauradas.',
      );
    }
  }
}
