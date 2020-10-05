import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:ricker_app/schemas/vehicle_schema.dart';
import 'package:ricker_app/screens/checklist_type_screen.dart';
import 'package:ricker_app/screens/home_screen.dart';
import 'package:ricker_app/services/LocalDatabaseServices.dart';
import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/services/vehicle_service.dart';
import 'package:ricker_app/widgets/custom_button.dart';
import 'package:ricker_app/widgets/custom_searchable.dart';
import 'package:ricker_app/widgets/try_again_button.dart';
import '../schemas/vehicle_model_schema.dart';
import '../services/vehicle_service.dart';

class VehicleScreen extends StatefulWidget {
  final bool cameFromHome;

  const VehicleScreen({Key key, this.cameFromHome = false}) : super(key: key);

  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final _vehicleModelController = TextEditingController();
  final _vehicleController = TextEditingController();
  LocalDatabaseHandler databaseHandler=new LocalDatabaseHandler();
  Future<List> _futures;
  CustomSearchableItem<VehicleModel> _selectedModel;
  CustomSearchableItem<Vehicle> _selectedVehicle;
  Connectivity connectivity=new Connectivity();
  bool loading=true;

  @override
  void initState() {
    super.initState();
    _initFutures();
  }

  addToDatabase(List values){
    databaseHandler.addVehicle(values[1]);
    databaseHandler.addVehicleModel(values[0]);
  }

  Future<void> _initFutures() async {
    print('init');
    var connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi){

      _futures = Future.wait([
        VehicleService.allModels(),
        VehicleService.allVehicles()
      ]);
      addToDatabase(await _futures);

    }
    else{
      print('no internet');
      _futures=Future.wait([]);

      _futures = Future.wait([
        databaseHandler.getVehicleModels(),
        databaseHandler.getVehicles()
      ]);
    }




    _setDefaultVehicle(await _futures);

    setState(() {
      loading=false;
    });
  }

  void _setDefaultVehicle(List values) {
    if (VehicleService.currentVehicleId != null) {
      List<Vehicle> vehicles = values[1];


      var vehicle = vehicles.firstWhere((v) => v.id == VehicleService.currentVehicleId, orElse: () => null);

      if (vehicle != null) {
        setState(() {
          _selectedModel = CustomSearchableItem<VehicleModel>(
            label: _getVehicleModelLabel(vehicle.vehicleModel),
            value: vehicle.vehicleModel,
          );

          _selectedVehicle = CustomSearchableItem<Vehicle>(
            label: _getVehicleLabel(vehicle),
            value: vehicle,
          );

          _vehicleModelController.text = _selectedModel.label;
          _vehicleController.text = _selectedVehicle.label;
        });
      }
    }
  }

  Future<void> _selectVehicle(Vehicle vehicle) async {
    ChecklistService.unsetCurrentChecklistAndChecklistForm();
    VehicleService.setCurrentVehicle(vehicle);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChecklistTypeScreen(vehicle: vehicle)
      )
    );

    ChecklistService.unsetCurrentChecklist();
  }

  List<Vehicle> _filterVehiclesByModel(List<Vehicle> vehicles) {
    return vehicles.where((v) => v.vehicleModelId == _selectedModel?.value?.id).toList();
  }

  void _navigateToHome() {
    if (widget.cameFromHome) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        )
      );
    }
  }

  String _getVehicleModelLabel(VehicleModel vehicleModel) {
    return '${vehicleModel.brand} ${vehicleModel.name}';
  }

  String _getVehicleLabel(Vehicle vehicle) {
    return vehicle.plate;
  }

  @override
  Widget build(BuildContext context) {
    print('Vehicle Screen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione seu veículo'),
        centerTitle: widget.cameFromHome ? false : true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _initFutures();
          });

          await _futures;
        },
        child: loading==true?Center(child: CircularProgressIndicator()):LayoutBuilder(
          builder: (context, viewportConstraints) => SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: FutureBuilder<List>(
                      future: _futures,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else 
                          if (snapshot.hasError) {
                          return TryAgainButton(
                            onPressed: () {
                              setState(() {
                                _initFutures();
                              });
                            },
                          );
                        }

                        List<VehicleModel> models = snapshot.data[0];
                        List<Vehicle> vehicles = _filterVehiclesByModel(snapshot.data[1]);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(height: 8.0,),
                            CustomSearchable<VehicleModel>(
                              controller: _vehicleModelController,
                              label: 'Modelo',
                              searchHint: 'Pesquise o modelo do veículo',
                              value: _selectedModel,
                              items: models.map((v) => CustomSearchableItem<VehicleModel>(
                                label: _getVehicleModelLabel(v),
                                value: v,
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _vehicleModelController.text = value.label;
                                  _selectedModel = value;
                                  _selectedVehicle = null;
                                });
                              },
                            ),
                            const SizedBox(height: 8.0,),
                            CustomSearchable<Vehicle>(
                              controller: _vehicleController,
                              label: 'Placa',
                              searchHint: 'Pesquise a placa do veículo',
                              value: _selectedVehicle,
                              enabled: _selectedModel != null,
                              items: vehicles.map((v) => CustomSearchableItem<Vehicle>(
                                label: _getVehicleLabel(v),
                                value: v,
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _vehicleController.text = value.label;
                                  _selectedVehicle = value;
                                });
                              },
                            ),
                          ],
                        );
                      },
                    )
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          !widget.cameFromHome
            ? Expanded(
                child: CustomButton(
                  onPressed: _navigateToHome,
                  label: 'IR PARA A HOME',
                  type: CustomButtonTypes.secondary,
                )
              )
            : SizedBox(),
          Expanded(
            child: CustomButton(
              onPressed: _selectedVehicle == null ? null : () {
                _selectVehicle(_selectedVehicle.value);
              },
              label: 'PROSSEGUIR',
              type: CustomButtonTypes.primary,
            )
          ),
        ],
      )
    );
  }
}
