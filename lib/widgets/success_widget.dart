import 'package:flutter/material.dart';
import 'package:ricker_app/config/app.example.dart';
import 'package:ricker_app/config/theme.dart';

class SuccessWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(Icons.check_circle, color: CustomTheme.SUCCESS_COLOR, size: 32.0),
        const SizedBox(height: 8.0),
        Text(
          'Obrigado!',
          style: Theme.of(context).textTheme.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        Text(
          'Dirija com segurança e seguindo os procedimentos operacionais da ${Config.APP_NAME}.',
          style: TextStyle(
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
