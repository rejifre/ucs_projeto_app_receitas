import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/ingredient_model.dart';
import '../../ui/app_colors.dart';
import 'edit_form_ingredient_widget.dart';

class EditFormIngredientListWidget extends StatefulWidget {
  final List<Ingredient>? initialIngredients;

  const EditFormIngredientListWidget({super.key, this.initialIngredients});

  @override
  EditFormIngredientListWidgetState createState() =>
      EditFormIngredientListWidgetState();
}

class EditFormIngredientListWidgetState
    extends State<EditFormIngredientListWidget> {
  final List<String> ingredientIds = [];
  final List<TextEditingController> ingredientNameControllers = [];
  final List<TextEditingController> ingredientQuantityControllers = [];
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.initialIngredients != null) {
      for (final ingredient in widget.initialIngredients!) {
        ingredientIds.add(ingredient.id);
        ingredientNameControllers.add(
          TextEditingController(text: ingredient.name),
        );
        ingredientQuantityControllers.add(
          TextEditingController(text: ingredient.quantity),
        );
      }
    }
  }

  void addIngredientField() {
    setState(() {
      ingredientIds.add(_uuid.v4());
      ingredientNameControllers.add(TextEditingController());
      ingredientQuantityControllers.add(TextEditingController());
    });
  }

  void removeIngredientField(int index) {
    setState(() {
      ingredientIds.removeAt(index);
      ingredientNameControllers[index].dispose();
      ingredientQuantityControllers[index].dispose();
      ingredientNameControllers.removeAt(index);
      ingredientQuantityControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final controller in ingredientNameControllers) {
      controller.dispose();
    }
    for (final controller in ingredientQuantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredientes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...List.generate(ingredientNameControllers.length, (index) {
          return Row(
            children: [
              Expanded(
                child: EditFormIngredientWidget(
                  id: ingredientIds[index],
                  nameController: ingredientNameControllers[index],
                  quantityController: ingredientQuantityControllers[index],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.delete),
                onPressed: () => removeIngredientField(index),
              ),
            ],
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("Adicionar ingrediente"),
          onPressed: addIngredientField,
        ),
      ],
    );
  }
}
