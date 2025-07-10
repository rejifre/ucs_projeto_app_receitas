import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
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

  /// Faz backup para arquivo local usando FilePicker
  Future<bool> backupToFile() async {
    try {
      _logger.i('Iniciando backup local...');

      // Coleta todos os dados
      final recipes = await _recipeService.getAll();
      final categories = await _categoryService.getAll();
      final tags = await _tagService.getAll();
      final allIngredients = await _ingredientService.getAll();
      final allInstructions = await _instructionService.getAll();
      final recipeCategories = await _categoryService.getAllRecipeCategories();
      final recipeTags = await _tagService.getAllRecipeTags();

      // Cria estrutura de backup simplificada e consistente
      final backupData = {
        'version': '1.0',
        'exportDate': DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
        'backup_info': {
          'description': 'Backup local das receitas',
          'totalItems':
              recipes.length +
              categories.length +
              tags.length +
              allIngredients.length +
              allInstructions.length,
          'created': DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
          'counts': {
            'recipes': recipes.length,
            'categories': categories.length,
            'tags': tags.length,
            'ingredients': allIngredients.length,
            'instructions': allInstructions.length,
            'recipe_tags': recipeTags.length,
            'recipe_categories': recipeCategories.length,
          },
        },
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
          'recipe_tags': recipeTags,
          'recipe_categories': recipeCategories,
        },
      };

      final jsonString = jsonEncode(backupData);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      // Nome do arquivo com timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'backup_receitas_$timestamp.json';

      _logger.i('Tentando salvar arquivo: $fileName');
      _logger.i(
        'Tamanho do backup: ${(bytes.length / 1024).toStringAsFixed(2)} KB',
      );

      // Tenta salvar o arquivo
      String? result = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar backup das receitas',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Platform.isAndroid || Platform.isIOS ? bytes : null,
      );

      // Se falhou com bytes (mobile), tenta salvar manualmente no desktop
      if (result != null && !Platform.isAndroid && !Platform.isIOS) {
        try {
          final file = File(result);
          await file.writeAsBytes(bytes);
          _logger.i('Arquivo salvo manualmente no desktop: $result');
        } catch (e) {
          _logger.e('Erro ao salvar arquivo manualmente: $e');
          return false;
        }
      }

      if (result == null) {
        _logger.w('Usuário cancelou o salvamento ou ocorreu erro.');
        return false;
      }

      final totalItems =
          recipes.length +
          categories.length +
          tags.length +
          allIngredients.length +
          allInstructions.length;

      _logger.i('✅ Backup salvo com sucesso!');
      _logger.i('📊 Estatísticas do backup:');
      _logger.i('   - ${recipes.length} receitas');
      _logger.i('   - ${categories.length} categorias');
      _logger.i('   - ${tags.length} tags');
      _logger.i('   - ${allIngredients.length} ingredientes');
      _logger.i('   - ${allInstructions.length} instruções');
      _logger.i('   - Total: $totalItems itens');

      return true;
    } catch (e, stackTrace) {
      _logger.e('❌ Erro ao fazer backup: $e');
      _logger.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Seleciona e restaura de um arquivo local
  Future<bool> selectAndRestoreFromFile() async {
    try {
      _logger.i('Iniciando seleção de arquivo para restauração...');

      // Abre o seletor de arquivos
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Selecione o arquivo de backup para restaurar',
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _logger.i('Seleção de arquivo cancelada pelo usuário.');
        return false;
      }

      final file = result.files.first;

      // Verifica se o arquivo tem um path (desktop) ou bytes (mobile)
      String jsonString;

      if (file.path != null) {
        // Desktop - lê do path
        final fileObj = File(file.path!);
        if (!await fileObj.exists()) {
          _logger.e('Arquivo não encontrado: ${file.path}');
          return false;
        }
        jsonString = await fileObj.readAsString();
        _logger.i('Arquivo lido do path: ${file.path}');
      } else if (file.bytes != null) {
        // Mobile - lê dos bytes
        jsonString = utf8.decode(file.bytes!);
        _logger.i('Arquivo lido dos bytes (mobile)');
      } else {
        _logger.e('Não foi possível acessar o conteúdo do arquivo');
        return false;
      }

      // Parse do JSON
      Map<String, dynamic> backupData;
      try {
        backupData = jsonDecode(jsonString);
      } catch (e) {
        _logger.e('Erro ao fazer parse do JSON: $e');
        return false;
      }

      // Restaura os dados
      return await restoreDataFromMap(backupData);
    } catch (e, stackTrace) {
      _logger.e('Erro ao selecionar e restaurar arquivo: $e');
      _logger.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Restaura dados de um arquivo local específico usando o caminho do arquivo
  /// [filePath] - Caminho absoluto para o arquivo de backup
  /// Returns: `true` se a restauração foi realizada com sucesso, `false` caso contrário
  Future<bool> restoreFromLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.e('Arquivo não encontrado: $filePath');
        return false;
      }
      final jsonString = await file.readAsString();
      Map<String, dynamic> backupData;
      try {
        backupData = jsonDecode(jsonString);
      } catch (e) {
        _logger.e('Erro ao fazer parse do JSON: $e');
        return false;
      }
      return await restoreDataFromMap(backupData);
    } catch (e, stackTrace) {
      _logger.e('Erro ao restaurar arquivo local: $e');
      _logger.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Restaura dados de um mapa (compatível com múltiplos formatos)
  Future<bool> restoreDataFromMap(Map<String, dynamic> backupData) async {
    try {
      _logger.i('Iniciando restauração...');

      // Detecta formato do backup e extrai dados
      Map<String, dynamic> dataSource;

      if (backupData.containsKey('data') && backupData['data'] is Map) {
        // Formato estruturado com seção 'data'
        dataSource = backupData['data'] as Map<String, dynamic>;
        _logger.i('Formato estruturado detectado');

        // Log de informações do backup
        if (backupData.containsKey('backup_info')) {
          final info = backupData['backup_info'];
          _logger.i('${info['description'] ?? 'Backup sem descrição'}');
          if (info['counts'] != null) {
            final counts = info['counts'];
            _logger.i('Itens no backup: ${counts.toString()}');
          }
        }
      } else {
        // Formato legado (dados no nível raiz)
        dataSource = backupData;
        _logger.i('Formato legado detectado');
      }

      int totalRestored = 0;
      List<String> errors = [];

      // Restaura na ordem correta (dependências primeiro)

      // 1. Categorias (sem dependências)
      if (dataSource.containsKey('categories')) {
        final categoriesData = dataSource['categories'] as List<dynamic>;
        int categoryCount = 0;

        for (final categoryJson in categoriesData) {
          try {
            final category = CategoryModel.fromMap(
              categoryJson as Map<String, dynamic>,
            );
            await _categoryService.insertOrReplace(category);
            categoryCount++;
          } catch (e) {
            errors.add('Categoria: $e');
            _logger.w('Erro ao restaurar categoria: $e');
          }
        }

        totalRestored += categoryCount;
        _logger.i(
          '✅ $categoryCount/${categoriesData.length} categorias restauradas',
        );
      }

      // 2. Tags (sem dependências)
      if (dataSource.containsKey('tags')) {
        final tagsData = dataSource['tags'] as List<dynamic>;
        int tagCount = 0;

        for (final tagJson in tagsData) {
          try {
            final tag = Tag.fromMap(tagJson as Map<String, dynamic>);
            await _tagService.insertOrReplace(tag);
            tagCount++;
          } catch (e) {
            errors.add('Tag: $e');
            _logger.w('Erro ao restaurar tag: $e');
          }
        }

        totalRestored += tagCount;
        _logger.i('$tagCount/${tagsData.length} tags restauradas');
      }

      // 3. Receitas (dependem de categorias)
      if (dataSource.containsKey('recipes')) {
        final recipesData = dataSource['recipes'] as List<dynamic>;
        int recipeCount = 0;

        for (final recipeJson in recipesData) {
          try {
            final recipe = Recipe.fromMap(recipeJson as Map<String, dynamic>);
            await _recipeService.insertOrReplace(recipe);
            recipeCount++;
          } catch (e) {
            errors.add('Receita: $e');
            _logger.w('Erro ao restaurar receita: $e');
          }
        }

        totalRestored += recipeCount;
        _logger.i('✅ $recipeCount/${recipesData.length} receitas restauradas');
      }

      // 4. Ingredientes (dependem de receitas)
      if (dataSource.containsKey('ingredients')) {
        final ingredientsData = dataSource['ingredients'] as List<dynamic>;
        int ingredientCount = 0;

        for (final ingredientJson in ingredientsData) {
          try {
            final ingredient = Ingredient.fromMap(
              ingredientJson as Map<String, dynamic>,
            );
            await _ingredientService.insertOrReplace(ingredient);
            ingredientCount++;
          } catch (e) {
            errors.add('Ingrediente: $e');
            _logger.w('⚠️ Erro ao restaurar ingrediente: $e');
          }
        }

        totalRestored += ingredientCount;
        _logger.i(
          '✅ $ingredientCount/${ingredientsData.length} ingredientes restaurados',
        );
      }

      // 5. Instruções (dependem de receitas)
      if (dataSource.containsKey('instructions')) {
        final instructionsData = dataSource['instructions'] as List<dynamic>;
        int instructionCount = 0;

        for (final instructionJson in instructionsData) {
          try {
            final instruction = Instruction.fromMap(
              instructionJson as Map<String, dynamic>,
            );
            await _instructionService.insertOrReplace(instruction);
            instructionCount++;
          } catch (e) {
            errors.add('Instrução: $e');
            _logger.w('⚠️ Erro ao restaurar instrução: $e');
          }
        }

        totalRestored += instructionCount;
        _logger.i(
          '✅ $instructionCount/${instructionsData.length} instruções restauradas',
        );
      }

      // Relatório final
      _logger.i('Restauração concluída!');
      _logger.i('Total restaurado: $totalRestored itens');

      if (errors.isNotEmpty) {
        _logger.w(' ${errors.length} erros durante a restauração:');
        for (final error in errors.take(5)) {
          // Mostra apenas os primeiros 5 erros
          _logger.w('   - $error');
        }
        if (errors.length > 5) {
          _logger.w('   ... e mais ${errors.length - 5} erros');
        }
      }

      return true;
    } catch (e, stackTrace) {
      _logger.e('Erro crítico durante restauração: $e');
      _logger.e('Stack trace: $stackTrace');
      return false;
    }
  }
}
