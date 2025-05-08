// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import '../../models/ingredient_model.dart';

class IngredientsDetailWidget extends StatelessWidget {
  final List<Ingredient> ingredients;
  final double fontSize = 16;
  const IngredientsDetailWidget({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return Text("Sem ingredientes.");
    }

    return Column(
      children: List.generate(ingredients.length, (index) {
        return Row(
          spacing: 10.0,
          children: [
            Text(
              ingredients[index].quantity,
              style: TextStyle(fontSize: fontSize),
            ),
            Text(ingredients[index].name, style: TextStyle(fontSize: fontSize)),
          ],
        );
      }),
    );
  }
}
