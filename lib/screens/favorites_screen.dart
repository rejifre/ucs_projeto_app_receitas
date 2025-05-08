import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> favoriteRecipes = [
      'Spaghetti Carbonara',
      'Chicken Curry',
      'Beef Stroganoff',
      'Vegetable Stir Fry',
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Favorite Recipes')),
      body:
          favoriteRecipes.isEmpty
              ? Center(
                child: Text(
                  'No favorite recipes yet!',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: favoriteRecipes.length,
                itemBuilder: (ctx, index) {
                  return ListTile(title: Text(favoriteRecipes[index]));
                },
              ),
    );
  }
}
