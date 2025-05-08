import 'package:flutter/material.dart';

import 'widgets/bottom_navigator_bar_widget.dart';

/// TODO: Implement the CategoriesScreen widget
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Breakfast', 'color': Colors.orange},
      {'title': 'Lunch', 'color': Colors.blue},
      {'title': 'Dinner', 'color': Colors.green},
      {'title': 'Snacks', 'color': Colors.purple},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Categorias')),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categories.length,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            onTap: () {
              // Handle category tap
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    categories[index]['color'] as Color,
                    categories[index]['color'] as Color,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                categories[index]['title'] as String,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
