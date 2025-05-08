import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipes_provider.dart';
import '../routes/routes.dart';
import '../ui/app_colors.dart';
import 'widgets/ingredients_detail_widget.dart';
import 'widgets/prepare_instruction_widget.dart';
import 'widgets/star_rating_widget.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeId = ModalRoute.of(context)!.settings.arguments as String;
    final provider = Provider.of<RecipesProvider>(context);
    final recipe = provider.recipes.firstWhere(
      (r) => r.id == recipeId,
      orElse:
          () => Recipe(
            id: '',
            title: 'Unknown',
            description: 'No description available',
            preparationTime: '0 min',
            ingredients: [],
            steps: [],
            score: 0,
            date: 'N/A',
          ),
    );

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
                recipe!.title,
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
              Text(recipe!.description, style: TextStyle(fontSize: 16.0)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "Ingredientes",
                  style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
                ),
              ),
              IngredientsDetailWidget(ingredients: recipe!.ingredients),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
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
