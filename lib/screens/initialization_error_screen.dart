import 'package:flutter/material.dart';
import 'package:ricker_app/screens/login_screen.dart';
import 'package:ricker_app/services/auth_service.dart';
import 'package:ricker_app/widgets/custom_button.dart';

class InitializationErrorScreens extends StatefulWidget {
  @override
  _InitializationErrorScreensState createState() => _InitializationErrorScreensState();
}

class _InitializationErrorScreensState extends State<InitializationErrorScreens> {
  var _loading = false;

  Future<void> _tryAgain() async {
    setState(() {
      _loading = true;
    });

    var initialWidget = await AuthService.getInitialWidget();

    setState(() {
      _loading = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => initialWidget,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    print('init error');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.signal_wifi_off,
                  size: 72.0,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Não foi possível conectar.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                CustomButton(
                  label: 'TENTAR NOVAMENTE',
                  type: CustomButtonTypes.primary,
                  onPressed: _tryAgain,
                ),
                const SizedBox(height: 8.0),
                CustomButton(
                  label: 'SAIR DA CONTA',
                  type: CustomButtonTypes.secondary,
                  onPressed: () {
                    AuthService.logout();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      )
                    );
                  },
                ),
              ],
            ),
      )
    );
  }
}
