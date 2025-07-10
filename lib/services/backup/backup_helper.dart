import 'package:logger/web.dart';
import '../category_service.dart';
import '../ingredient_service.dart';
import '../instruction_service.dart';
import '../recipe_service.dart';
import '../tag_service.dart';

class BackupHelper {
  final RecipeService _recipeService = RecipeService();
  final IngredientService _ingredientService = IngredientService();
  final InstructionService _instructionService = InstructionService();
  final CategoryService _categoryService = CategoryService();
  final TagService _tagService = TagService();
  final Logger _logger = Logger();

  BackupHelper();

  // Método auxiliar para limpar todas as receitas
  Future<void> _clearAllRecipes() async {
    try {
      await _recipeService.deleteAll();
      _logger.i('Todas as receitas foram removidas do banco local.');
    } catch (e) {
      _logger.e('Erro ao limpar receitas: $e');
      rethrow;
    }
  }

  // Método auxiliar para limpar todas as  categorias
  Future<void> _clearAllCategories() async {
    try {
      await _categoryService.deleteAll();
      _logger.i('Todas as categorias foram removidas do banco local.');
    } catch (e) {
      _logger.e('Erro ao limpar categorias: $e');
      rethrow;
    }
  }

  // Método auxiliar para limpar todas as tags
  Future<void> _clearAllTags() async {
    try {
      await _tagService.deleteAll();
      _logger.i('Todas as tags foram removidas do banco local.');
    } catch (e) {
      _logger.e('Erro ao limpar tags: $e');
      rethrow;
    }
  }

  // Método auxiliar para limpar todos os ingredientes
  Future<void> _clearAllIngredients() async {
    try {
      await _ingredientService.deleteAll();
      _logger.i('Todos os ingredientes foram removidos do banco local.');
    } catch (e) {
      _logger.e('Erro ao limpar ingredientes: $e');
      rethrow;
    }
  }

  // Método auxiliar para limpar todas as instruções
  Future<void> _clearAllInstructions() async {
    try {
      await _instructionService.deleteAll();
      _logger.i('Todas as instruções foram removidas do banco local.');
    } catch (e) {
      _logger.e('Erro ao limpar instruções: $e');
      rethrow;
    }
  }

  // Método auxiliar para limpar todos os dados
  Future<void> clearAllData() async {
    // Limpa primeiro os dados dependentes (ingredientes e instruções)
    await _clearAllIngredients();
    await _clearAllInstructions();

    // Depois limpa as receitas (que podem ter FK para categorias/tags)
    await _clearAllRecipes();

    // Por último, limpa categorias e tags
    await _clearAllCategories();
    await _clearAllTags();
  }
}
