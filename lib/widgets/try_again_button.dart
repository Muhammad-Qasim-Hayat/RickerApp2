import 'package:flutter/material.dart';
import 'package:ricker_app/utils/constants.dart';

import 'custom_button.dart';

class TryAgainButton extends StatelessWidget {
  final Function onPressed;
  final String message;

  const TryAgainButton({Key key, @required this.onPressed, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Oops!', style: Theme.of(context).textTheme.headline.copyWith(color: Theme.of(context).accentColor),),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message ?? NETWORK_ERROR_MESSAGE,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).accentColor,
              height: 1.5
            ),
          ),
        ),
        CustomButton(
          onPressed: onPressed,
          label: 'Tentar de novo',
          type: CustomButtonTypes.primary,
        )
      ],
    );
  }
}
