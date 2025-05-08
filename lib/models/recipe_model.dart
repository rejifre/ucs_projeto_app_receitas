// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'ingredient_model.dart';
import 'instruction_model.dart';

class Recipe {
  String id;
  String title;
  String description;
  double score;
  String date;
  String preparationTime;
  List<Ingredient> ingredients;
  List<Instruction> steps;
  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.score,
    required this.date,
    required this.preparationTime,
    this.ingredients = const [],
    this.steps = const [],
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    double? score,
    String? date,
    String? preparationTime,
    List<Ingredient>? ingredients,
    List<Instruction>? steps,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      score: score ?? this.score,
      date: date ?? this.date,
      preparationTime: preparationTime ?? this.preparationTime,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'score': score,
      'date': date,
      'preparationTime': preparationTime,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      score: map['score'] as double,
      date: map['date'] as String,
      preparationTime: map['preparationTime'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Recipe.fromJson(String source) =>
      Recipe.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, description: $description, score: $score, date: $date, preparationTime: $preparationTime, ingredients: $ingredients, steps: $steps)';
  }

  @override
  bool operator ==(covariant Recipe other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.score == score &&
        other.date == date &&
        other.preparationTime == preparationTime &&
        listEquals(other.ingredients, ingredients) &&
        listEquals(other.steps, steps);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        score.hashCode ^
        date.hashCode ^
        preparationTime.hashCode ^
        ingredients.hashCode ^
        steps.hashCode;
  }
}
