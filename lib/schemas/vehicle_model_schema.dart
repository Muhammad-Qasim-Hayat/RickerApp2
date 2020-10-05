import 'package:flutter/foundation.dart';

class VehicleModel {
  final String id;
  final String brand;
  final String name;

  String get fullName => '$brand $name';

  VehicleModel({
    @required this.id,
    @required this.brand,
    @required this.name,
  });

  VehicleModel.fromJson(Map json)
      : id = json['id'],
      brand = json['brand'],
      name = json['name'];



  Map<String,dynamic> toMap(){ // used when inserting data to the database
    return <String,dynamic>{

      'id': id,
      'brand' : brand,
      'name' : name
    };
  }



  @override
  String toString() => 'VehicleModel(id: $id, brand: $brand, name: $name)';
}
