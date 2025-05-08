import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../routes/routes.dart';
import '../providers/recipes_provider.dart';
import '../ui/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> _recipes = [];

  void _navigateToAdd() async {
    await Navigator.pushNamed(context, Routes.editRecipe, arguments: null);
  }

  void _navigateToDetail(String recipeId) async {
    await Navigator.pushNamed(context, Routes.recipe, arguments: recipeId);
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipesProvider>(context);
    _recipes = recipeProvider.recipes;

    return Scaffold(
      appBar: AppBar(title: Text("Receitas")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: ListView.builder(
          itemCount: _recipes.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.mainColor,
                  child: Text(
                    index.toString(),
                    style: TextStyle(color: AppColors.lightBackgroundColor),
                  ),
                ),
                title: Text(_recipes[index].title),
                subtitle: Text(
                  "${_recipes[index].ingredients.length} ingredientes.",
                ),
                tileColor: AppColors.lightBackgroundColor,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Icon(Icons.timer_sharp, size: 15),
                    Text(_recipes[index].preparationTime),
                  ],
                ),
                onTap: () => _navigateToDetail(_recipes[index].id),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        tooltip: 'Adicionar Receita',
        backgroundColor: AppColors.buttonMainColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
