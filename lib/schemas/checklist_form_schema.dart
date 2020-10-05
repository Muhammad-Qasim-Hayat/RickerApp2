import 'package:flutter/foundation.dart';

import 'package:ricker_app/schemas/checklist_item_form_schema.dart';
import 'package:ricker_app/schemas/checklist_schema.dart';
import 'package:ricker_app/schemas/vehicle_schema.dart';
import 'package:ricker_app/utils/helper.dart';

enum ChecklistTypes {
  daily,
  monthly,
  replacement,
}

class ChecklistForm {
  final String id;
  final Checklist checklist;
  final Vehicle vehicle;
  final List<ChecklistItemForm> items;
  ChecklistTypes type;
  String signatureUrl;

  ChecklistForm fromDatabase({
    String id,
    Checklist checklist,
    Vehicle vehicle,
    List<ChecklistItemForm> items,
    String type,
    String signatureUrl
  }){
    return ChecklistForm(
      id: id,
      checklist: checklist,
      vehicle: vehicle,
      items: items,
      type: Helper.getEnumFromString(ChecklistTypes.values, type),
      signatureUrl: signatureUrl
    );
  }

  ChecklistForm({
    @required this.id,
    @required this.checklist,
    @required this.type,
    @required this.vehicle,
    @required this.items,
    @required this.signatureUrl,
  });

  ChecklistForm.fromJson(Map json)
    : id = json['id'],
      checklist = Checklist.fromJson(json['checklist']),
      type = Helper.getEnumFromString(ChecklistTypes.values, json['type']),
      signatureUrl = json['signatureUrl'],
      vehicle = Vehicle.fromJson(json['vehicle']),
      items = json['checkedItems'].map<ChecklistItemForm>((i) => ChecklistItemForm.fromJson(i)).toList();


  ChecklistForm.fromJsonIncomplete(Map json)
      : id = json['id'],
        checklist = null,
        type = Helper.getEnumFromString(ChecklistTypes.values, json['type']),
        signatureUrl = json['signatureUrl'],
        vehicle = null,
        items = null;


  @override
  String toString() {
    return 'ChecklistForm(id: $id, checklist: $checklist, type: $type, vehicle: $vehicle, items: $items)';
  }
}
