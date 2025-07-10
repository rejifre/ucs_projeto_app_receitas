import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe_model.dart';
import '../../providers/recipes_provider.dart';
import '../../routes/routes.dart';
import '../../ui/app_colors.dart';
import 'ingredients_detail_widget.dart';
import 'prepare_instruction_widget.dart';
import '../widgets/star_rating_widget.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, this.recipeId});

  final String? recipeId;

  @override
  Widget build(BuildContext context) {
    // Verificação mais segura para obter o recipeId

    // Se não há ID válido, mostra tela de erro
    if (recipeId?.isEmpty ?? true) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receita')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Receita não encontrada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('ID da receita não foi fornecido'),
            ],
          ),
        ),
      );
    }

    final provider = Provider.of<RecipesProvider>(context);
    final recipe = provider.recipes.firstWhere(
      (r) => r.id == recipeId,
      orElse:
          () => Recipe(
            id: '',
            title: 'Receita não encontrada',
            description: 'Esta receita não existe ou foi removida.',
            preparationTime: '0 min',
            ingredients: [],
            steps: [],
            score: 0,
            date: 'N/A',
          ),
    );

    // Se a receita não foi encontrada, mostra tela de erro
    if (recipe.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receita')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant_menu_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Receita não encontrada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('ID: $recipeId'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.edit),
            label: Text("Editar"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.buttonMainColor,
            ),
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                Routes.editRecipe,
                arguments: recipe,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StarRatingWidget(rating: recipe.score),
                    Text(recipe.date),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                margin: EdgeInsets.symmetric(vertical: 10.0),
                color: AppColors.lightBackgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.0,
                      children: [
                        Icon(Icons.timer_sharp),
                        Column(
                          children: [
                            Text('PREP:'),
                            Text(recipe.preparationTime),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.0,
                      children: [
                        Icon(Icons.kitchen_outlined),
                        Column(
                          children: [
                            Text('INGR:'),
                            Text(recipe.ingredients.length.toString()),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.0,
                      children: [
                        Icon(Icons.breakfast_dining_outlined),
                        Column(
                          children: [
                            Text('PASSOS:'),
                            Text(recipe.steps.length.toString()),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "Descrição",
                  style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
                ),
              ),
              Text(recipe.description, style: TextStyle(fontSize: 16.0)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "Ingredientes",
                  style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
                ),
              ),
              IngredientsDetailWidget(ingredients: recipe.ingredients),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "Modo de Preparo",
                  style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
                ),
              ),
              PrepareInstructionWidget(steps: recipe.steps),
            ],
          ),
        ),
      ),
    );
  }
}
