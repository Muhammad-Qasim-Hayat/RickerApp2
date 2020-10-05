import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  final String text;

  const ScreenTitle(this.text, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.display1.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold
      ),
      textAlign: TextAlign.center,
    );
  }
}
