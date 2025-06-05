// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import '../../models/instruction_model.dart';
import '../../ui/app_colors.dart';

class PrepareInstructionWidget extends StatelessWidget {
  final List<Instruction> steps;
  const PrepareInstructionWidget({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Text("Sem modo de preparo.");
    }

    return Column(
      children: List.generate(steps.length, (index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.mainColor,
            child: Text(
              steps[index].stepOrder.toString(),
              style: TextStyle(color: AppColors.lightBackgroundColor),
            ),
          ),
          title: Text(steps[index].description),
        );
      }),
    );
  }
}
