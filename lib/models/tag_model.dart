// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Tag {
  String name;
  String description;

  Tag({required this.name, required this.description});

  Tag copyWith({String? name, String? description}) {
    return Tag(
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': name, 'description': description};
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      name: map['name'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tag.fromJson(String source) =>
      Tag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Tag(name: $name, description: $description)';

  @override
  bool operator ==(covariant Tag other) {
    if (identical(this, other)) return true;

    return other.name == name && other.description == description;
  }

  @override
  int get hashCode => name.hashCode ^ description.hashCode;
}
