import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/ingredient_model.dart';
import '../models/instruction_model.dart';
import '../models/recipe_model.dart';

class RecipeGeneratorService {
  /// Method to generate a random recipe
  final Random _random = Random();

  RecipeGeneratorService();

  /// Method to get a random Lorem Ipsum text
  /// Returns a String with the recipe
  Future<String> getLoremIpsum() async {
    const paragraphType = 'normal';
    const paragraphCount = 4;

    final url = Uri.parse(
      'https://randommer.io/api/Text/LoremIpsum?loremType=$paragraphType&type=paragraphs&number=$paragraphCount',
    );
    final headers = {
      'X-Api-Key': '997d1de03aaf4418a3a2dce238699be3',
      'Content-Type': 'application/json',
    };
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final String data = jsonDecode(response.body);
      Logger().i('Resposta: $data');
      return data;
    } else {
      throw Exception('Erro ao buscar Lorem Ipsum: ${response.statusCode}');
    }
  }

  /// Method to generate a random recipe
  /// Returns an object of type Recipe
  /// If the result is empty, it returns null
  Future<Recipe?> getRecipe() async {
    final result = await getLoremIpsum();

    if (result.isEmpty) return null;

    final splitValues = result.split('<br>');

    while (splitValues.length < 3) {
      splitValues.add(result.split('.')[0]);
    }
    Recipe recipe = _getRecipeModel(splitValues[0].split('.'));
    _getIngredients(splitValues[1].split('.'), recipe);
    _getInstructions(splitValues[2].split('.'), recipe);

    return recipe;
  }

  /// Generates a Recipe model from a list of string values.
  /// Ensures safe access and fallback for missing or malformed data.
  Recipe _getRecipeModel(List<String> values) {
    final title =
        (values.isNotEmpty && values[0].split(',').isNotEmpty)
            ? values[0].split(',')[0].trim()
            : 'Receita Aleatória';
    final description =
        (values.length > 1 && values[1].trim().isNotEmpty)
            ? values[1].trim()
            : 'Descrição não disponível.';

    return Recipe(
      id: Uuid().v4(),
      title: title,
      description: description,
      score: double.parse((_random.nextDouble() * 5).toStringAsFixed(1)),
      date: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now().toUtc()),
      preparationTime: _getRandomPreparationTime(),
    );
  }

  /// Method to generate a list of ingredients
  /// Returns a list of objects of type Ingredient
  void _getIngredients(List<String> values, Recipe recipe) {
    final ingredients = <Ingredient>[];
    final end = min(_getNumberOfItems(), values.length);

    for (var i = 0; i < end; i++) {
      final ingredient = values[i].split(',')[0].trim();
      ingredients.add(
        Ingredient(
          id: Uuid().v4(),
          name: ingredient,
          quantity: _getRandomQuantity(),
          recipeId: recipe.id,
        ),
      );
    }
    recipe.ingredients = ingredients;
  }

  /// Method to generate a list of instructions
  /// Returns a list of objects of type Instruction
  void _getInstructions(List<String> values, Recipe recipe) {
    final steps = <Instruction>[];
    final end = min(_getNumberOfItems(), values.length);

    for (var i = 0; i < end; i++) {
      final instruction = values[i].trim();
      if (instruction.isNotEmpty) {
        steps.add(
          Instruction(
            id: Uuid().v4(),
            description: instruction,
            stepOrder: i + 1,
            recipeId: recipe.id,
          ),
        );
      }
    }
    recipe.steps = steps;
  }

  /// Method to generate a random quantity
  /// Returns a String with the quantity
  String _getRandomQuantity() {
    final quantity = _random.nextInt(1000) + 1;

    switch (_random.nextInt(2)) {
      case 0:
        return '$quantity g';
      case 1:
        return '$quantity ml';
    }

    return quantity.toString();
  }

  /// Method to generate a random preparation time
  /// Returns a String with the preparation time
  String _getRandomPreparationTime() {
    final hours = _random.nextInt(3);
    final minutes = _random.nextInt(60);

    return '$hours h $minutes m';
  }

  /// Method to get a random number of items.
  /// Returns an int with the number of items
  int _getNumberOfItems({int min = 3, int max = 9}) {
    return min + _random.nextInt(max - min + 1);
  }
}
