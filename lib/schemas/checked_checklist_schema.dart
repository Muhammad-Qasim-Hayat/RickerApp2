import 'package:flutter/foundation.dart';
import 'package:ricker_app/schemas/user_schema.dart';
import 'package:ricker_app/services/date_service.dart';
import 'package:ricker_app/utils/helper.dart';

import 'checklist_form_schema.dart';

class CheckedChecklistVehicle {
  final String brand;
  final String name;
  final String plate;

  CheckedChecklistVehicle({
    @required this.brand,
    @required this.name,
    @required this.plate,
  });

  CheckedChecklistVehicle.fromJson(Map vehicle, Map vehicleModel)
      : brand = vehicleModel['brand'],
        name = vehicleModel['name'],
        plate = vehicle['plate'];

  CheckedChecklistVehicle.fromDatabase(Map map)
      : this.brand = map['brand'],
        this.name = map['name'],
        this.plate = map['plate'];
}

class CheckedChecklistItem {
  final String comments;
  final bool hasProblem;
  final List<String> images;
  final String name;
  final bool optional;

  CheckedChecklistItem({
    @required this.comments,
    @required this.hasProblem,
    @required this.images,
    @required this.name,
    @required this.optional,
  });

  CheckedChecklistItem.fromJson(Map json)
      : comments = json['comments'],
        hasProblem = json['hasProblem'],
        images = json['images'].map<String>((i) => i.toString()).toList(),
        name = json['item']['name'],
        optional = json['optional'];

  CheckedChecklistItem.fromDatabase(Map map, List<String> images)
      : comments = map["comments"],
        hasProblem = map['hasProblem'] == 0 ? false : true,
        images = images,
        name = map['name'],
        optional = map['optional'] == 0 ? false : true;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "comments": comments,
      "hasProblem": hasProblem == true ? 1 : 0,
      "name": name,
      "optional": optional == true ? 1 : 0
    };
  }
}

class CheckedChecklist {
  final String id;
  final User replacementUser;
  final CheckedChecklistVehicle vehicle;
  final List<CheckedChecklistItem> checkedItems;
  final ChecklistTypes type;
  final String signatureUrl;
  final String createdAt;
  final String finishedAt;
  final double lat;
  final double lng;
  final int sequentialNumber;

  CheckedChecklist({
    @required this.id,
    @required this.replacementUser,
    @required this.vehicle,
    @required this.checkedItems,
    @required this.type,
    @required this.signatureUrl,
    @required this.createdAt,
    @required this.finishedAt,
    @required this.lat,
    @required this.lng,
    @required this.sequentialNumber,
  });

  CheckedChecklist.fromJson(Map json)
      : id = json['id'],
        replacementUser = json['replacementUser'] != null
            ? User.fromJson(json['replacementUser'])
            : null,
        vehicle = CheckedChecklistVehicle.fromJson(
            json['vehicle'], json['vehicleModel']),
        checkedItems = List<Map>.from(json['checkedItems'])
            .map<CheckedChecklistItem>((i) => CheckedChecklistItem.fromJson(i))
            .toList(),
        type = Helper.getEnumFromString<ChecklistTypes>(
            ChecklistTypes.values, json['type']),
        signatureUrl = json['signatureUrl'],
        createdAt = DateService.fullDateAndTime(json['createdAt']),
        finishedAt = DateService.fullDateAndTime(json['finishedAt']),
        lat = json['lat'],
        lng = json['lng'],
        sequentialNumber = json['sequentialNumber'];

  CheckedChecklist.fromDatabase(Map json, CheckedChecklistVehicle vehicle,
      List<CheckedChecklistItem> item)
      : id = json['id'],
        replacementUser = json['replacementUser'] != null
            ? User.fromJson(json['replacementUser'])
            : null,
        vehicle = vehicle,
        checkedItems = item,
        type = Helper.getEnumFromString<ChecklistTypes>(
            ChecklistTypes.values, json['type']),
        signatureUrl = json['signatureUrl'],
        createdAt = json['createdAt'],
        finishedAt = json['finishedAt'],
        lat = double.parse(json['lat']),
        lng = double.parse(json['lng']),
        sequentialNumber = json['sequentialNumber'];

   printIt(){
     print('\n\n\n\n\n\n');
     print(id.toString());
     print(replacementUser.toString());
     print(vehicle.toString());
     print(checkedItems.toString());
     print(type.toString());
     print(signatureUrl.toString());
     print(createdAt.toString());
     print(finishedAt.toString());
     print(lat.toString());
     print(lng.toString());
     print(sequentialNumber);
     print('\n\n\n');
     print("CheckedChecklistVehicle\n");
     print(vehicle.name.toString());
     print(vehicle.brand.toString());
     print(vehicle.plate.toString());
     print('\n\n\n');

     checkedItems.forEach((element) {
       print("CheckedChecklistItem\n");
       print(element.name);
       print(element.hasProblem);
       print(element.images.toString());
       print(element.comments);
       print(element.optional);
       print('\n');

     });




   }
}
