import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ricker_app/config/app.example.dart';
import 'package:ricker_app/schemas/checklist_form_schema.dart';
import 'package:ricker_app/screens/checklist_form_success_screen.dart';
import 'package:ricker_app/screens/replacement_request_screen.dart';
import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/utils/helper.dart';
import 'package:ricker_app/widgets/checklist_form_items_list.dart';
import 'package:ricker_app/widgets/custom_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class ChecklistFormPreviewScreen extends StatefulWidget {
  @override
  _ChecklistFormPreviewScreenState createState() => _ChecklistFormPreviewScreenState();
}

class _ChecklistFormPreviewScreenState extends State<ChecklistFormPreviewScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _permissionNotGranted = false;

  Future<Position> _getLocation() async {
    Helper.showLoadingDialog(context);

    if (await Permission.location.request().isGranted) {
      setState(() {
        _permissionNotGranted = false;
      });

      return await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }

    Navigator.of(context).pop();

    setState(() {
      _permissionNotGranted = true;
    });

    Helper.showError(_scaffoldKey, 'Não foi possível obter sua localização.');

    return null;
  }

  Future<void> _finishChecklist() async {
    var position = await _getLocation();

    if (position != null) {
      try {
        await ChecklistService.finishCheckedChecklist(position.latitude, position.longitude);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => ChecklistFormSuccessScreen(),
          ),
          (route) => false,
        );
      } catch (e) {
        if (e.type == DioErrorType.RESPONSE) {
          Helper.showError(
            _scaffoldKey,
            e.response.data['message'],
            duration: const Duration(seconds: 5),
          );
        } else {
          Helper.showNetworkError(_scaffoldKey);
        }

        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ChecklistFormPreviewScreen');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Revise sua checklist feita'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _permissionNotGranted
              ? Container(
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.warning,
                          size: 32.0,
                          color: Color(0x77000000),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'Precisamos da sua localização para finalizar sua checklist. Por favor, verifique se deu as devidas permissões de acesso ou vá nas configurações do aplicativo ${Config.APP_NAME} para concedê-las.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
            : Container(),
            ChecklistFormItemsList(
              checklist: ChecklistService.currentChecklist,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomButton(
        onPressed: () async {
          if (ChecklistService.currentChecklistForm.type == ChecklistTypes.replacement) {
            var position = await _getLocation();

            if (position != null) {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReplacementRequestScreen(
                    checklist: ChecklistService.currentChecklist,
                    vehicle: ChecklistService.currentChecklistForm.vehicle,
                    position: position,
                  )
                )
              );
            }
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Confirmar checklist?'),
                content: Text('Após confirmar, não será mais possível fazer alterações.'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    textColor: Colors.grey,
                    child: Text('CANCELAR'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _finishChecklist();
                    },
                    textColor: Theme.of(context).primaryColor,
                    child: Text('SIM'),
                  ),
                ],
              )
            );
          }
        },
        label: ChecklistService.currentChecklistForm.type == ChecklistTypes.replacement
          ? 'PROSSEGUIR'
          : 'CONFIRMAR',
        type: ChecklistService.currentChecklistForm.type == ChecklistTypes.replacement
          ? CustomButtonTypes.primary
          : CustomButtonTypes.success,
      ),
    );
  }
}
