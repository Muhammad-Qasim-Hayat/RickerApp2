import 'package:flutter/material.dart';
import 'package:ricker_app/screens/home_screen.dart';
import 'package:ricker_app/services/auth_service.dart';
import 'package:ricker_app/utils/helper.dart';
import 'package:ricker_app/widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _registrationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _passwordFocus = FocusNode();

  bool _submitting = false;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
    });

    try {
      bool authenticated = await AuthService.authenticate(
        _registrationController.text,
        _passwordController.text
      );

      if (authenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
          (route) => false,
        );
      } else {
        _passwordController.clear();
        Helper.showError(_scaffoldKey, 'Matrícula ou senha incorretos.');
      }
    } catch (e) {
      Helper.showNetworkError(_scaffoldKey);
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Login');
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset('assets/images/logo.png', height: 79.0,),
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
                    onFieldSubmitted: (v) => _submit(),
                    focusNode: _passwordFocus,
                  ),
                  const SizedBox(height: 8.0,),
                  CustomButton(
                    label: 'ENTRAR',
                    onPressed: _submitting ? null : _submit,
                    type: CustomButtonTypes.primary,
                    submitting: _submitting,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
