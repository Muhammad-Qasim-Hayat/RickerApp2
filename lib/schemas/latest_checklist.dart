import 'package:flutter/foundation.dart';
import 'package:ricker_app/schemas/checklist_form_schema.dart';
import 'package:ricker_app/utils/helper.dart';

class LatestChecklist {
  final String id;
  final String vehicleName;
  final bool hasProblem;
  final DateTime createdAt;
  final DateTime finishedAt;
  final ChecklistTypes type;

  LatestChecklist({
    @required this.id,
    @required this.vehicleName,
    @required this.hasProblem,
    @required this.createdAt,
    @required this.finishedAt,
    @required this.type,
  });

  LatestChecklist.fromJson(Map json)
    : id = json['id'],
      vehicleName = json['vehicleName'],
      hasProblem = json['hasProblem'].toString()=='true'?true:false,
      createdAt = DateTime.parse(json['createdAt']),
      finishedAt = DateTime.parse(json['finishedAt']),
      type = Helper.getEnumFromString(ChecklistTypes.values, json['type']);


  Map<String,dynamic> toMap(){ // used when inserting data to the database
    return <String,dynamic>{
      'id': id,
      'vehicleName' : vehicleName,
      'hasProblem' : hasProblem.toString(),
      'createdAt':createdAt.toString(),
      'finishedAt':finishedAt.toString(),
      'type': type.toString(),
    };
  }

}
