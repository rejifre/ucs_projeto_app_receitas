// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Instruction {
  String id;
  int stepOrder;
  String description;
  String recipeId;

  Instruction({
    required this.id,
    required this.stepOrder,
    required this.description,
    required this.recipeId,
  });

  Instruction copyWith({
    String? id,
    int? stepOrder,
    String? description,
    String? recipeId,
  }) {
    return Instruction(
      id: id ?? this.id,
      stepOrder: stepOrder ?? this.stepOrder,
      description: description ?? this.description,
      recipeId: recipeId ?? this.recipeId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'step_order': stepOrder,
      'description': description,
      'recipe_id': recipeId,
    };
  }

  factory Instruction.fromMap(Map<String, dynamic> map) {
    return Instruction(
      id: map['id'] as String,
      stepOrder: map['step_order'] as int,
      description: map['description'] as String,
      recipeId: map['recipe_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Instruction.fromJson(String source) =>
      Instruction.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Instruction(id: $id, step_order: $stepOrder, description: $description, recipe_Id: $recipeId)';
  }

  @override
  bool operator ==(covariant Instruction other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.stepOrder == stepOrder &&
        other.description == description &&
        other.recipeId == recipeId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        stepOrder.hashCode ^
        description.hashCode ^
        recipeId.hashCode;
  }
}
