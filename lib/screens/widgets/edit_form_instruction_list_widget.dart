import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/instruction_model.dart';
import '../../ui/app_colors.dart';
import 'edit_form_instruction_widget.dart';

class EditFormInstructionListWidget extends StatefulWidget {
  final List<Instruction>? initialInstructions;

  const EditFormInstructionListWidget({super.key, this.initialInstructions});

  @override
  EditFormInstructionListWidgetState createState() =>
      EditFormInstructionListWidgetState();
}

class EditFormInstructionListWidgetState
    extends State<EditFormInstructionListWidget> {
  final List<String> instructionIds = [];
  final List<TextEditingController> instructionDescriptionControllers = [];
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.initialInstructions != null) {
      for (final instruction in widget.initialInstructions!) {
        instructionIds.add(instruction.id);
        instructionDescriptionControllers.add(
          TextEditingController(text: instruction.description),
        );
      }
    }
  }

  void addInstructionField() {
    setState(() {
      instructionIds.add(_uuid.v4()); // Generate a unique ID
      instructionDescriptionControllers.add(TextEditingController());
    });
  }

  void removeInstructionField(int index) {
    setState(() {
      instructionIds.removeAt(index);
      instructionDescriptionControllers[index].dispose();
      instructionDescriptionControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final controller in instructionDescriptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instruções', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...List.generate(instructionDescriptionControllers.length, (index) {
          return Row(
            children: [
              Expanded(
                child: EditFormInstructionWidget(
                  id: instructionIds[index],
                  stepOrder: index + 1,
                  descriptionController:
                      instructionDescriptionControllers[index],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.delete),
                onPressed: () => removeInstructionField(index),
              ),
            ],
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("Adicionar instrução"),
          onPressed: addInstructionField,
        ),
      ],
    );
  }
}
