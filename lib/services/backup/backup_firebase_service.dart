import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';

import '../../models/category_model.dart';
import '../../models/ingredient_model.dart';
import '../../models/instruction_model.dart';
import '../../models/recipe_model.dart';
import '../../models/tag_model.dart';
import '../category_service.dart';
import '../ingredient_service.dart';
import '../instruction_service.dart';
import '../recipe_service.dart';
import '../tag_service.dart';
import 'backup_helper.dart';

class BackupFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RecipeService _recipeService = RecipeService();
  final IngredientService _ingredientService = IngredientService();
  final InstructionService _instructionService = InstructionService();
  final CategoryService _categoryService = CategoryService();
  final TagService _tagService = TagService();
  final Logger _logger = Logger();
  final BackupHelper _backupHelper = BackupHelper();

  BackupFirebaseService();

  // Backup para Firestore
  Future<bool> backupToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) {
      _logger.e(
        'Usuário não logado. Não é possível fazer backup para Firestore.',
      );
      return false;
    }

    try {
      _logger.i('Iniciando backup para Firebase Firestore...');

      // Coleta todos os dados
      final recipes = await _recipeService.getAll();
      final categories = await _categoryService.getAll();
      final tags = await _tagService.getAll();

      // Coleta ingredientes e instruções para todas as receitas
      List<Ingredient> allIngredients = await _ingredientService.getAll();
      List<Instruction> allInstructions = await _instructionService.getAll();

      final batch = _firestore.batch();
      final backupRef = _firestore.collection('users/${user.uid}/backup');

      // Primeiro, limpa os dados existentes do usuário no Firestore
      _logger.i('Limpando backup anterior no Firestore...');
      final existingDocs = await backupRef.get();
      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      // Salva os dados organizados por tipo
      batch.set(backupRef.doc('recipes'), {
        'data': recipes.map((recipe) => recipe.toMap()).toList(),
        'count': recipes.length,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      batch.set(backupRef.doc('categories'), {
        'data': categories.map((category) => category.toMap()).toList(),
        'count': categories.length,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      batch.set(backupRef.doc('tags'), {
        'data': tags.map((tag) => tag.toMap()).toList(),
        'count': tags.length,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      batch.set(backupRef.doc('ingredients'), {
        'data': allIngredients.map((ingredient) => ingredient.toMap()).toList(),
        'count': allIngredients.length,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      batch.set(backupRef.doc('instructions'), {
        'data':
            allInstructions.map((instruction) => instruction.toMap()).toList(),
        'count': allInstructions.length,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      // Salva associações de receitas com categorias e tags
      final recipeCategories = await _categoryService.getAllRecipeCategories();
      final recipeTags = await _tagService.getAllRecipeTags();
      batch.set(backupRef.doc('recipe_categories'), {
        'data': recipeCategories,
        'count': recipeCategories.length,
        'lastUpdate': FieldValue.serverTimestamp(),
      });
      batch.set(backupRef.doc('recipe_tags'), {
        'data': recipeTags,
        'count': recipeTags.length,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      // Salva informações gerais do backup
      batch.set(backupRef.doc('backup_info'), {
        'version': '1.0',
        'createdAt': DateFormat('dd/MM/yy HH:mm').format(DateTime.now()),
        'userEmail': user.email,
        'summary': {
          'recipes': recipes.length,
          'categories': categories.length,
          'tags': tags.length,
          'ingredients': allIngredients.length,
          'instructions': allInstructions.length,
          'recipeCategories': recipeCategories.length,
          'recipeTags': recipeTags.length,
        },
      });

      await batch.commit();
      _logger.i(
        'Backup completo para Firestore concluído para o usuário: ${user.uid}',
      );
      return true;
    } catch (e) {
      _logger.e('Erro ao fazer backup para Firestore: $e');
      return false;
    }
  }

  // Restauração do Firestore
  Future<bool> restoreFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) {
      _logger.e('Usuário não logado. Não é possível restaurar do Firestore.');
      return false;
    }

    try {
      _logger.i('Iniciando restauração do Firebase Firestore...');
      final backupRef = _firestore.collection('users/${user.uid}/backup');

      // Verifica se existe backup
      final backupInfo = await backupRef.doc('backup_info').get();
      if (!backupInfo.exists) {
        _logger.w('Nenhum backup encontrado no Firestore para este usuário.');
        return false;
      }

      final backupSummary =
          backupInfo.data()!['summary'] as Map<String, dynamic>;
      _logger.i('Backup encontrado: ${backupSummary.toString()}');

      // Limpa todos os dados locais
      _logger.i('Limpando dados locais antes da restauração...');
      await _backupHelper.clearAllData();

      int totalRestored = 0;

      // Restaura categorias primeiro
      final categoriesDoc = await backupRef.doc('categories').get();
      if (categoriesDoc.exists) {
        final categoriesData = categoriesDoc.data()!['data'] as List<dynamic>;
        for (final categoryJson in categoriesData) {
          final category = CategoryModel.fromMap(categoryJson);
          await _categoryService.insertOrReplace(category);
        }
        totalRestored += categoriesData.length;
        _logger.i(
          '${categoriesData.length} categorias restauradas do Firestore.',
        );
      }

      // Restaura tags
      final tagsDoc = await backupRef.doc('tags').get();
      if (tagsDoc.exists) {
        final tagsData = tagsDoc.data()!['data'] as List<dynamic>;
        for (final tagJson in tagsData) {
          final tag = Tag.fromMap(tagJson);
          await _tagService.insertOrReplace(tag);
        }
        totalRestored += tagsData.length;
        _logger.i('${tagsData.length} tags restauradas do Firestore.');
      }

      // Restaura ingredientes
      final ingredientsDoc = await backupRef.doc('ingredients').get();
      if (ingredientsDoc.exists) {
        final ingredientsData = ingredientsDoc.data()!['data'] as List<dynamic>;
        for (final ingredientJson in ingredientsData) {
          final ingredient = Ingredient.fromMap(ingredientJson);
          await _ingredientService.insertOrReplace(ingredient);
        }
        totalRestored += ingredientsData.length;
        _logger.i(
          '${ingredientsData.length} ingredientes restaurados do Firestore.',
        );
      }

      // Restaura instruções
      final instructionsDoc = await backupRef.doc('instructions').get();
      if (instructionsDoc.exists) {
        final instructionsData =
            instructionsDoc.data()!['data'] as List<dynamic>;
        for (final instructionJson in instructionsData) {
          final instruction = Instruction.fromMap(instructionJson);
          await _instructionService.insertOrReplace(instruction);
        }
        totalRestored += instructionsData.length;
        _logger.i(
          '${instructionsData.length} instruções restauradas do Firestore.',
        );
      }

      // Restaura receitas
      final recipesDoc = await backupRef.doc('recipes').get();
      if (recipesDoc.exists) {
        final recipesData = recipesDoc.data()!['data'] as List<dynamic>;
        for (final recipeJson in recipesData) {
          final recipe = Recipe.fromMap(recipeJson);
          await _recipeService.insertOrReplace(recipe);
        }
        totalRestored += recipesData.length;
        _logger.i('${recipesData.length} receitas restauradas do Firestore.');
      }

      // Restaura associações de receitas com categorias
      final recipeCategoriesDoc =
          await backupRef.doc('recipe_categories').get();
      if (recipeCategoriesDoc.exists) {
        final recipeCategoriesData =
            recipeCategoriesDoc.data()!['data'] as List<dynamic>;
        for (final categoryJson in recipeCategoriesData) {
          await _categoryService.insertRecipeCategory(categoryJson);
        }
        totalRestored += recipeCategoriesData.length;
        _logger.i(
          '${recipeCategoriesData.length} associações de categorias de receitas restauradas do Firestore.',
        );
      }

      // Restaura associações de receitas com tags
      final recipeTagsDoc = await backupRef.doc('recipe_tags').get();
      if (recipeTagsDoc.exists) {
        final recipeTagsData = recipeTagsDoc.data()!['data'] as List<dynamic>;
        for (final tagJson in recipeTagsData) {
          await _tagService.insertRecipeTag(tagJson);
        }
        totalRestored += recipeTagsData.length;
        _logger.i(
          '${recipeTagsData.length} associações de tags de receitas restauradas do Firestore.',
        );
      }

      _logger.i(
        'Restauração completa do Firestore concluída! Total de $totalRestored itens restaurados para o usuário: ${user.uid}',
      );
      return true;
    } catch (e) {
      _logger.e('Erro ao restaurar do Firestore: $e');
      return false;
    }
  }

  // --- Verificar se existe backup no Firestore ---
  Future<Map<String, dynamic>?> getFirestoreBackupInfo() async {
    final user = _auth.currentUser;
    if (user == null) {
      _logger.e(
        'Usuário não logado. Não é possível verificar backup no Firestore.',
      );
      return null;
    }

    try {
      final backupRef = _firestore.collection('users/${user.uid}/backup');
      final backupInfo = await backupRef.doc('backup_info').get();

      if (!backupInfo.exists) {
        _logger.i('Nenhum backup encontrado no Firestore para este usuário.');
        return null;
      }

      final data = backupInfo.data()!;
      _logger.i('Informações do backup encontrado: ${data.toString()}');
      return data;
    } catch (e) {
      _logger.e('Erro ao verificar backup no Firestore: $e');
      return null;
    }
  }

  // --- Deletar backup do Firestore ---
  Future<bool> deleteFirestoreBackup() async {
    final user = _auth.currentUser;
    if (user == null) {
      _logger.e(
        'Usuário não logado. Não é possível deletar backup do Firestore.',
      );
      return false;
    }

    try {
      _logger.i('Deletando backup do Firestore...');
      final backupRef = _firestore.collection('users/${user.uid}/backup');
      final existingDocs = await backupRef.get();

      final batch = _firestore.batch();
      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _logger.i('Backup deletado com sucesso do Firestore.');
      return true;
    } catch (e) {
      _logger.e('Erro ao deletar backup do Firestore: $e');
      return false;
    }
  }
}
