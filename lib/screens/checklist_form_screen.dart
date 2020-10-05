import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ricker_app/config/theme.dart';
import 'package:ricker_app/schemas/checklist_form_schema.dart';
import 'package:ricker_app/schemas/checklist_item_form_schema.dart';
import 'package:ricker_app/schemas/checklist_item_schema.dart';
import 'package:ricker_app/schemas/checklist_schema.dart';
import 'package:ricker_app/schemas/vehicle_schema.dart';
import 'package:ricker_app/screens/checklist_form_preview_screen.dart';
import 'package:ricker_app/screens/checklist_item_form_screen.dart';
import 'package:ricker_app/screens/signature_screen.dart';
import 'package:ricker_app/services/LocalDatabaseServices.dart';
import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/utils/helper.dart';
import 'package:ricker_app/widgets/checklist_form_items_list.dart';
import 'package:ricker_app/widgets/custom_button.dart';
import 'package:ricker_app/widgets/try_again_button.dart';

class ChecklistFormScreen extends StatefulWidget {
  final Vehicle vehicle;
  final ChecklistTypes type;
  final Checklist checklist;
  final bool centerTitle;

  const ChecklistFormScreen({
    Key key,
    @required this.vehicle,
    @required this.type,
    @required this.checklist,
    this.centerTitle = false,
  }) : super(key: key);

  @override
  _ChecklistFormScreenState createState() => _ChecklistFormScreenState();
}

class _ChecklistFormScreenState extends State<ChecklistFormScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<ChecklistForm> _future;
  LocalDatabaseHandler databaseHandler = new LocalDatabaseHandler();
  bool loading = true;
  bool connected;

  @override
  void initState() {
    super.initState();
    _startFutureBuilder();
  }

  String get _checklistTypeTitle {
    switch (widget.type) {
      case ChecklistTypes.daily:
        return 'diária';
      case ChecklistTypes.monthly:
        return 'mensal';
      default:
        return 'de substituição';
    }
  }

  Checklist checklist;

  Future<void> _startFutureBuilder() async {
    ChecklistService.unsetCurrentChecklistForm();

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      _future = ChecklistService.startCheckedChecklist(
          widget.checklist.id, widget.vehicle.id, widget.type);

      await _future;

      connected = true;

      var x = await _future;

      databaseHandler.addCheckListFunction(x);
    } else {
      _future = databaseHandler.getCheckListFunction(
          widget.checklist.id, widget.vehicle.id, widget.type);
      var x = await _future;
      ChecklistService.currentChecklist = x.checklist;
      connected = false;
      checklist = x.checklist;
      ChecklistService.currentChecklistForm = x;
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _navigateToChecklistItemForm(
      ChecklistItem checklistItem, ChecklistItemForm checklistItemForm) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChecklistItemFormScreen(
              checklistItem: checklistItem,
              checklistItemForm: checklistItemForm,
            )));

    setState(() {});
  }

  Future<void> _navigateTo(Widget screen) async {
    Helper.showLoadingDialog(context);

    try {
      await ChecklistService.verifyIntegrity();

      Navigator.of(context).pop();

      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => screen));

      setState(() {
        _startFutureBuilder();
      });
    } catch (e) {
      if (e.type == DioErrorType.RESPONSE) {
        Helper.showError(
          _scaffoldKey,
          e.response.data['message'],
          duration: const Duration(seconds: 5),
        );

        setState(() {
          _startFutureBuilder();
        });
      } else {
        Helper.showNetworkError(_scaffoldKey);
      }

      Navigator.of(context).pop();
    }
  }

  Future<void> _navigateToSignatureScreen() async {
    if (ChecklistService.currentChecklistForm.signatureUrl != null) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Deseja assinar novamente?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: Navigator.of(context).pop,
                    textColor: Colors.grey,
                    child: Text('CANCELAR'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateTo(SignatureScreen());
                    },
                    textColor: Theme.of(context).primaryColor,
                    child: Text('ASSINAR NOVAMENTE'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateTo(ChecklistFormPreviewScreen());
                    },
                    textColor: CustomTheme.SUCCESS_COLOR,
                    child: Text('REVISAR CHECKLIST'),
                  ),
                ],
              ));
    } else {
      _navigateTo(SignatureScreen());
    }
  }

  Future<void> _deleteCurrentChecklist() async {
    Helper.showLoadingDialog(context, popLast: true);

    try {
      await ChecklistService.deleteUnfinishedChecklist();
      Navigator.of(context).pop();
      Navigator.of(context).pop(true);
    } catch (e) {
      Helper.showNetworkError(_scaffoldKey);
      Navigator.of(context).pop();
    }
  }

  void _askForDeleteCurrentCheckedChecklist() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Deletar sua checklist?'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  textColor: Colors.grey,
                  child: Text('CANCELAR'),
                ),
                FlatButton(
                  onPressed: _deleteCurrentChecklist,
                  textColor: Colors.red,
                  child: Text('SIM'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Faça sua checklist $_checklistTypeTitle'),
        centerTitle: widget.centerTitle,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _askForDeleteCurrentCheckedChecklist,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _startFutureBuilder();
          });

          await _future;
        },
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : LayoutBuilder(
                builder: (context, viewportConstraints) =>
                    SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: FutureBuilder<ChecklistForm>(
                          future: _future,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child: TryAgainButton(
                                  onPressed: () {
                                    setState(() {
                                      _startFutureBuilder();
                                    });
                                  },
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.directions_car,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      widget.vehicle.vehicleModel.fullName,
                                      style: Theme.of(context).textTheme.title,
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                ChecklistFormItemsList(
                                  ///TODO:here
                                  checklist: connected
                                      ? ChecklistService.currentChecklist
                                      : checklist,
                                  onTap: _navigateToChecklistItemForm,
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: CustomButton(
        label: 'PROSSEGUIR',
        onPressed:
            ChecklistService.allDone() ? _navigateToSignatureScreen : null,
        type: CustomButtonTypes.primary,
      ),
    );
  }
}
