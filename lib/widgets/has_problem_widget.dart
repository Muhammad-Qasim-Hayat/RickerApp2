import 'package:flutter/material.dart';
import 'package:ricker_app/config/theme.dart';

class HasProblemWidget extends StatelessWidget {
  final bool hasProblem;
  final String withProblemText;
  final String withoutProblemText;

  const HasProblemWidget(this.hasProblem, {Key key, this.withProblemText = 'Com problemas', this.withoutProblemText = 'Sem problemas'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return hasProblem
      ? Text(
          withProblemText,
          style: Theme.of(context).textTheme.body2.copyWith(color: Colors.red),
          // style: Theme.of(context).textTheme.subtitle,
        )
      : Text(
          withoutProblemText,
          style: Theme.of(context).textTheme.body2.copyWith(color: CustomTheme.SUCCESS_COLOR),
        );
  }
}
