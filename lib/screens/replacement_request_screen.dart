import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ricker_app/schemas/checklist_schema.dart';
import 'package:ricker_app/schemas/user_schema.dart';
import 'package:ricker_app/schemas/vehicle_schema.dart';
import 'package:ricker_app/screens/checklist_form_success_screen.dart';
import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/utils/helper.dart';
import 'package:ricker_app/widgets/custom_button.dart';
import 'package:ricker_app/widgets/custom_text_field.dart';
import 'package:geolocator/geolocator.dart';

class ReplacementRequestScreen extends StatefulWidget {
  final Vehicle vehicle;
  final Checklist checklist;
  final Position position;

  const ReplacementRequestScreen({
    Key key,
    @required this.vehicle,
    @required this.checklist,
    @required this.position,
  }) : super(key: key);

  @override
  _ReplacementRequestScreenState createState() => _ReplacementRequestScreenState();
}

class _ReplacementRequestScreenState extends State<ReplacementRequestScreen> {
  final _registrationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _passwordFocus = FocusNode();
  var _submitting = false;

  Future<void> _askForSubmit() async {
    var replacementDriver = await _authenticateDriverForReplacement();

    _passwordController.clear();

    if (replacementDriver != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirmar substituição de ${widget.vehicle.vehicleModel.fullName} para ${replacementDriver.name}?'),
          actions: <Widget>[
            FlatButton(
              child: Text("CANCELAR"),
              textColor: Colors.black54,
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text("SIM"),
              textColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).pop();
                _submit(replacementDriver.id);
              },
            ),
          ],
        )
      );
    }
  }

  Future<User> _authenticateDriverForReplacement() async {
    setState(() {
      _submitting = true;
    });

    try {
      var user = await ChecklistService.requestVehicleReplacement(
        widget.checklist.id,
        _registrationController.text,
        _passwordController.text
      );

      return user;
    } on DioError catch (e) {
      if (e.type == DioErrorType.RESPONSE) {
        _passwordController.clear();
        Helper.showError(_scaffoldKey, e.response.data['message'] ?? 'Matrícula ou senha incorretos.');
      } else {
        Helper.showNetworkError(_scaffoldKey);
      }
    } finally {
      setState(() {
        _submitting = false;
      });
    }

    return null;
  }

  Future<void> _submit(String userId) async {
    Helper.showLoadingDialog(context);

    try {
      await ChecklistService.finishCheckedChecklist(
        widget.position.latitude,
        widget.position.longitude,
        userId,
      );

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

  @override
  Widget build(BuildContext context) {
    print('Replace Request Screen');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Confirmar substituição'),
      ),
      body: LayoutBuilder(
        builder: (context, viewportConstraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    const SizedBox(height: 16.0,),
                    Text(
                      'O motorista que vai receber o veículo deve digitar a matrícula e senha dele nos campos abaixo:',
                      style: Theme.of(context).textTheme.subhead,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32.0,),
                    CustomTextField(
                      controller: _registrationController,
                      enabled: !_submitting,
                      label: 'Matrícula',
                      hintText: 'Ex: 155',
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (v) {
                        _passwordFocus.requestFocus();
                      },
                    ),
                    const SizedBox(height: 16.0,),
                    CustomTextField(
                      controller: _passwordController,
                      obscureText: true,
                      enabled: !_submitting,
                      label: 'Senha',
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (v) => _askForSubmit(),
                      focusNode: _passwordFocus,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ),
      bottomNavigationBar: CustomButton(
        label: 'CONFIRMAR',
        onPressed: _submitting ? null : _askForSubmit,
        type: CustomButtonTypes.success,
        submitting: _submitting,
      ),
    );
  }
}
