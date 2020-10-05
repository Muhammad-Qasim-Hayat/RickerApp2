import 'package:flutter/foundation.dart';
import 'package:ricker_app/schemas/checklist_item_schema.dart';

class Checklist {
  final String id;
  final List<ChecklistItem> items;

  Checklist({
    @required this.id,
    @required this.items,
  });

  Checklist fromDatabase({
  String id,
    List<ChecklistItem> items
}){
    return Checklist(
      id: id,
      items: items,
    );
  }

  Checklist.fromJson(Map json)
    : id = json['id'],
      items = json['items'].map<ChecklistItem>((i) => ChecklistItem.fromJson(i)).toList();

  @override
  String toString() => 'Checklist(id: $id, items: $items)';
}
