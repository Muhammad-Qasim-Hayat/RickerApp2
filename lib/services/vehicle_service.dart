import 'package:ricker_app/schemas/checklist_schema.dart';
import 'package:ricker_app/schemas/vehicle_schema.dart';
import 'package:ricker_app/services/http_service.dart';
import 'package:ricker_app/services/storage_service.dart';

import '../schemas/vehicle_model_schema.dart';

abstract class VehicleService {
  static const String CURRENT_VEHICLE_ID_KEY = 'currentVehicleId';
  static String _currentVehicleId;
  static String get currentVehicleId => _currentVehicleId;

  static Future<void> loadCurrentVehicle() async {
    var vehicleId = await StorageService.read(CURRENT_VEHICLE_ID_KEY);
    _currentVehicleId = vehicleId;

  }

  static Future<void> setCurrentVehicle(Vehicle vehicle) async {
    await StorageService.write(CURRENT_VEHICLE_ID_KEY, vehicle.id);
    _currentVehicleId = vehicle.id;
  }

  static Future<List<VehicleModel>> allModels() async {
    var response = await HttpService.get('/vehicle-models?limit=false');
    return response.data.map<VehicleModel>((d) => VehicleModel.fromJson(d)).toList();
  }

  static Future<List<Vehicle>> allVehicles() async {
    var response = await HttpService.get('/vehicles?limit=false');
    return response.data.map<Vehicle>((d) => Vehicle.fromJson(d)).toList();
  }

  static Future<Checklist> getChecklist(String vehicleId) async {
    var response = await HttpService.get('/vehicles/$vehicleId/checklist');
    return Checklist.fromJson(response.data['checklist']);
  }
}
