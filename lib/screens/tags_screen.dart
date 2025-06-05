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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Select a tag to explore recipes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          SearchBar(
            hintText: 'Buscar tag....',
            onChanged:
                (value) => {
                  // Handle search logic here
                },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  color: category['color'] as Color,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      category['title'] as String,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onTap: () {
                      // Handle category tap
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
