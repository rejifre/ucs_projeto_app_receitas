import 'package:flutter/material.dart';

class EditFormInstructionWidget extends StatelessWidget {
  final String id;
  final int stepOrder;
  final TextEditingController descriptionController;

  const EditFormInstructionWidget({
    super.key,
    required this.id,
    required this.stepOrder,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Text(stepOrder.toString()),
        Expanded(
          child: TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Instrução'),
          ),
        ),
      ],
    );
  }
}
