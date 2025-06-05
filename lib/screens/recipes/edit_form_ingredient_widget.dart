import 'package:flutter/material.dart';

class EditFormIngredientWidget extends StatelessWidget {
  final String id;
  final TextEditingController nameController;
  final TextEditingController quantityController;

  const EditFormIngredientWidget({
    super.key,
    required this.id,
    required this.nameController,
    required this.quantityController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Obrigatório' : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: quantityController,
            decoration: const InputDecoration(labelText: 'Quantidade'),
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Obrigatório' : null,
          ),
        ),
      ],
    );
  }
}
