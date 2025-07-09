class PersonModel {
  String id;
  String name;
  String observation;

  PersonModel(this.id, this.name, this.observation);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'observation': observation,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      map['id'] as String,
      map['name'] as String,
      map['observation'] as String,
    );
  }
}
