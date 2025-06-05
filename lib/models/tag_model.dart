// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Tag {
  String id;
  String name;

  Tag({required this.id, required this.name});

  Tag copyWith({String? id, String? name}) {
    return Tag(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(id: map['id'] as String, name: map['name'] as String);
  }

  String toJson() => json.encode(toMap());

  factory Tag.fromJson(String source) =>
      Tag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Tag(id: $id, name: $name)';

  @override
  bool operator ==(covariant Tag other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
