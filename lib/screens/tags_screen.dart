import 'package:flutter/material.dart';

/// TODO: Implement the TagsScreen widget
class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Breakfast', 'color': Colors.orange},
      {'title': 'Lunch', 'color': Colors.blue},
      {'title': 'Dinner', 'color': Colors.green},
      {'title': 'Snacks', 'color': Colors.purple},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Tags')),
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
