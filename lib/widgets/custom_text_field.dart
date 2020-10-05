import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final bool obscureText;
  final Function(String) onFieldSubmitted;
  final String hintText;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final FocusNode focusNode;
  final Function onTap;
  final Function(String) onChanged;
  final bool readonly;
  final int maxLines;
  final String initialValue;

  const CustomTextField({
    Key key,
    @required this.label,
    this.controller,
    this.enabled = true,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.hintText,
    this.textInputAction,
    this.keyboardType,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.readonly = false,
    this.maxLines = 1,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const borderWidth = 1.5;

    return Column(
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 16.0,
            color: enabled
              ? CustomTheme.PRIMARY_COLOR
              : CustomTheme.PRIMARY_LIGHT_COLOR,
          ),
        ),
        const SizedBox(height: 8.0,),
        InkWell(
          onTap: onTap != null && enabled ? () {} : null,
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            focusNode: focusNode,
            onChanged: onChanged,
            readOnly: readonly,
            onTap: onTap,
            maxLines: maxLines,
            initialValue: initialValue,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: const EdgeInsets.all(16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: borderWidth,
                  color: CustomTheme.PRIMARY_COLOR,
                ),
                borderRadius: BorderRadius.zero,
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: borderWidth,
                  color: CustomTheme.PRIMARY_LIGHT_COLOR,
                ),
                borderRadius: BorderRadius.zero,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: borderWidth,
                  color: CustomTheme.PRIMARY_COLOR,
                ),
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        )
      ],
    );
  }
}
