import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe_model.dart';
import '../../routes/routes.dart';
import '../../providers/recipes_provider.dart';
import '../../ui/app_colors.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  List<Recipe> _recipes = [];

  void _navigateToDetail(String recipeId) async {
    await Navigator.pushNamed(
      context,
      Routes.recipeDetail,
      arguments: recipeId,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipesProvider>().recipes;
    _recipes = recipeProvider;

    return Padding(
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
    );
  }
}
