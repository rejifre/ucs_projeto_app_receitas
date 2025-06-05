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
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8.0,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    ingredients[index].quantity,
                    style: TextStyle(fontSize: fontSize),
                  ),
                  Expanded(
                    child: Text(
                      ingredients[index].name,
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              height: 1,
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
          ],
        );
      }),
    );
  }
}
