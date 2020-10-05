import 'package:flutter/foundation.dart';

class ChecklistItem {
  final String id;
  final String name;
  final String description;
  final bool requiredPhoto;
  final bool optional;


  ChecklistItem fromDatabase({
    String id,
    String name,
    String description,
    bool requiredPhoto,
    bool optional,
    }){
    return ChecklistItem(
      id: id,
      name: name,
      description: description,
      requiredPhoto: requiredPhoto,
      optional: optional,
    );
}

  ChecklistItem({
    @required this.id,
    @required this.name,
    @required this.requiredPhoto,
    @required this.optional,
    this.description,
  });

  ChecklistItem.fromJson(Map json)
    : id = json['id'],
      name = json['name'],
      description = json['description'],
      requiredPhoto = json['requiredPhoto'],
      optional = json['optional'];

  @override
  String toString() {
    return 'ChecklistItem(id: $id, name: $name, description: $description, requiredPhoto: $requiredPhoto, optional: $optional)';
  }
}
