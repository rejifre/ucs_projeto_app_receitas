// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Ingredient {
  String id;
  String name;
  String quantity;
  String recipeId;
  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.recipeId,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    String? quantity,
    String? recipeId,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      recipeId: recipeId ?? this.recipeId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'quantity': quantity,
      'recipe_id': recipeId,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as String,
      recipeId: map['recipe_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Ingredient.fromJson(String source) =>
      Ingredient.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, quantity: $quantity, recipe_id: $recipeId)';
  }

  @override
  bool operator ==(covariant Ingredient other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.quantity == quantity &&
        other.recipeId == recipeId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ quantity.hashCode ^ recipeId.hashCode;
  }
}
