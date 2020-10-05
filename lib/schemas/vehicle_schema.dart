import 'package:flutter/foundation.dart';

import 'package:ricker_app/schemas/vehicle_model_schema.dart';

class Vehicle {
  final String id;
  final String vehicleModelId;
  final String plate;
  final VehicleModel vehicleModel;

  Vehicle({
    @required this.id,
    @required this.vehicleModelId,
    @required this.plate,
    @required this.vehicleModel,
  });

  Vehicle.fromJson(Map json)
    : id = json['id'],
      vehicleModelId = json['vehicleModelId'],
      plate = json['plate'],
      vehicleModel = VehicleModel.fromJson(json['vehicleModel']);

  Map<String,dynamic> toMap(){ // used when inserting data to the database
    return <String,dynamic>{

      'id': id,
      'vehicleModelId' : vehicleModelId,
      'plate' : plate,
      'vehicleModel' : vehicleModel.toMap().toString()
    };
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, vehicleModelId: $vehicleModelId, plate: $plate, vehicleModel: $vehicleModel)';
  }
}
