import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ricker_app/schemas/checklist_form_schema.dart';
import 'package:ricker_app/schemas/checklist_schema.dart';
import 'package:ricker_app/schemas/user_schema.dart';
import 'package:ricker_app/schemas/vehicle_schema.dart';
import 'package:ricker_app/screens/checklist_form_screen.dart';
import 'package:ricker_app/services/LocalDatabaseServices.dart';
import 'package:ricker_app/services/auth_service.dart';
import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/services/vehicle_service.dart';
import 'package:ricker_app/utils/helper.dart';
import 'package:ricker_app/widgets/custom_button.dart';
import 'package:ricker_app/widgets/try_again_button.dart';

class ChecklistTypeScreen extends StatefulWidget {
  final Vehicle vehicle;

  const ChecklistTypeScreen({Key key, @required this.vehicle})
      : super(key: key);

  @override
  _ChecklistTypeScreenState createState() => _ChecklistTypeScreenState();
}

class _ChecklistTypeScreenState extends State<ChecklistTypeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool connected;
  Checklist localCheckList;

  bool driver;

  Future<Checklist> _future;

  @override
  void initState() {
    super.initState();
    getFutures();
  }

  LocalDatabaseHandler databaseHandler = new LocalDatabaseHandler();

  getFutures() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (AuthService.currentUser.role == UserRoles.driver) {
        driver = true;
      } else {
        driver = false;
      }
      _future = VehicleService.getChecklist(widget.vehicle.id)
          .then(_setCurrentChecklist);
      toDatabase();
      ChecklistService.setCurrentChecklist(await _future);

      connected = true;
    } else {
      driver = await databaseHandler.role();

      _future = databaseHandler.getTypeScreen(widget.vehicle.id);

      ChecklistService.setCurrentChecklist(await _future);

      connected = false;
      localCheckList = await _future;
    }
    setState(() {});
  }

  toDatabase() async {
    var x = await _future;
    databaseHandler.addToTypeScreenTable(x, widget.vehicle.id);
  }

  Future<Checklist> _setCurrentChecklist(Checklist checklist) async {
    ChecklistService.setCurrentChecklist(checklist);
    return checklist;
  }

  void _navigateToChecklistForm(
      BuildContext context, ChecklistTypes type) async {
    bool checklistDeleted = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChecklistFormScreen(
              vehicle: widget.vehicle,
              type: type,
              checklist: ChecklistService.currentChecklist,
            )));

    if (checklistDeleted != null && checklistDeleted) {
      Helper.showSnackbar(_scaffoldKey, 'Sua checklist foi removida.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ChecklistService.currentChecklist == null) {
      getFutures();
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else
      return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Selecione o tipo da checklist'),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: FutureBuilder<Checklist>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return TryAgainButton(
                          message: snapshot.error is DioError &&
                                  (snapshot.error as DioError)
                                          .response
                                          .statusCode ==
                                      404
                              ? 'Nenhuma checklist foi criada para este modelo de veículo.'
                              : null,
                          onPressed: () {
                            setState(() {
                              _future =
                                  VehicleService.getChecklist(widget.vehicle.id)
                                      .then(_setCurrentChecklist);
                            });
                          },
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomButton(
                            label: 'DIÁRIA',
                            onPressed: () {
                              _navigateToChecklistForm(
                                  context, ChecklistTypes.daily);
                            },
                            type: CustomButtonTypes.primary,
                          ),
                          const SizedBox(height: 16.0),
                          !driver
                              ? CustomButton(
                                  label: 'MENSAL',
                                  onPressed: () {
                                    _navigateToChecklistForm(
                                        context, ChecklistTypes.monthly);
                                  },
                                  type: CustomButtonTypes.primary,
                                )
                              : const SizedBox(),
                          !driver
                              ? const SizedBox(height: 16.0)
                              : const SizedBox(),
                          CustomButton(
                            label: 'SUBSTITUIÇÃO',
                            onPressed: () {
                              _navigateToChecklistForm(
                                  context, ChecklistTypes.replacement);
                            },
                            type: CustomButtonTypes.secondary,
                          ),
                        ],
                      );
                    }),
              ),
            ),
          ));
  }
}
