import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:ucs_projeto_app_receitas/models/recipe_model.dart';
import 'package:uuid/uuid.dart';
import '../models/ingredient_model.dart';
import '../models/instruction_model.dart';

class RecipeGeneratorService {
  /// Method to generate a random recipe
  Random _random = Random();

  RecipeGeneratorService();

  /// Method to get a random Lorem Ipsum text
  /// Returns a String with the recipe
  Future<String> getLoremIpsum() async {
    const paragraphType = 'normal';
    const paragraphCount = 2;

    final url = Uri.parse(
      'https://randommer.io/api/Text/LoremIpsum?loremType=$paragraphType&type=paragraphs&number=$paragraphCount',
    );
    final headers = {
      'X-Api-Key': 'dbebdf0e06a64a2590004804dfc2b135', // Exemplo de header
      'Content-Type': 'application/json',
    };
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as String;
      Logger().i('Resposta: $data');
      return data;
    } else {
      throw Exception('Erro ao buscar Lorem Ipsum');
    }
  }

  /// Method to generate a random recipe
  /// Returns an object of type Recipe
  /// If the result is empty, it returns null
  Future<Recipe?> getRecipe() async {
    final result = await getLoremIpsum();

    if (result.isEmpty) return null;

    final values = result.split('.');

    Recipe recipe = _getRecipeModel(values);

    _getIngredientes(values, recipe);

    _getInstructions(values, recipe);

    return recipe;
  }

  /// Method to generate a random recipe
  /// Returns an object of type Recipe
  Recipe _getRecipeModel(List<String> values) {
    final recipe = Recipe(
      id: Uuid().v4(),
      title: values[0].split(',')[0],
      description: values[1],
      score: double.parse((_random.nextDouble() * 5).toStringAsFixed(1)),
      date: DateFormat('dd/MM/yyyy kk:mm').format(DateTime.now().toUtc()),
      preparationTime: _getRandomPreparationTime(),
    );
    return recipe;
  }

  /// Method to generate a list of ingredients
  /// Returns a list of objects of type Ingredient
  void _getIngredientes(List<String> values, Recipe recipe) {
    final ingredients = <Ingredient>[];
    for (var i = 0; i < _getRandomNumber(); i++) {
      final ingredient = values[i].split(',')[0];
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
    for (var i = 0; i < _getRandomNumber(); i++) {
      final instruction = values[i].split(',')[0];
      steps.add(
        Instruction(
          id: Uuid().v4(),
          description: instruction,
          stepOrder: i + 1,
          recipeId: recipe.id,
        ),
      );
    }
    recipe.steps = steps;
  }

  /// Method to generate a random quantity
  /// Returns a String with the quantity
  _getRandomQuantity() {
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
  _getRandomPreparationTime() {
    final hours = _random.nextInt(3);
    final minutes = _random.nextInt(60);

    return '$hours h $minutes m';
  }

  _getRandomNumber() {
    final value = _random.nextInt(9) + 1;
    if (value < 3) {
      return 4;
    }
    return value;
  }
}
