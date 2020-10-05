import 'package:flutter/material.dart';

import '../config/theme.dart';

enum CustomButtonTypes {
  primary,
  primaryLight,
  secondary,
  success,
}

class CustomButton extends StatelessWidget {
  final Function onPressed;
  final CustomButtonTypes type;
  final String label;
  final bool submitting;

  const CustomButton({
    Key key,
    @required this.onPressed,
    @required this.type,
    @required this.label,
    this.submitting = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color backgroundColor;

    switch (type) {
      case CustomButtonTypes.primary:
        backgroundColor = CustomTheme.PRIMARY_COLOR;
        break;
      case CustomButtonTypes.primaryLight:
        backgroundColor = CustomTheme.PRIMARY_LIGHT_COLOR;
        break;
      case CustomButtonTypes.secondary:
        backgroundColor = CustomTheme.SECONDARY_COLOR;
        break;
      case CustomButtonTypes.success:
        backgroundColor = CustomTheme.SUCCESS_COLOR;
        break;
    }

    return Container(
      height: 50.0,
      child: FlatButton(
        onPressed: onPressed,
        textColor: Colors.white,
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        disabledColor: CustomTheme.LIGHT_COLOR,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: submitting
            ? const SizedBox(
                width: 16.0,
                height: 16.0,
                child: const CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(CustomTheme.PRIMARY_COLOR),
                  strokeWidth: 2.0,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
        ),
      ),
    );
  }
}
