import 'package:flutter/material.dart';
import 'package:ricker_app/config/theme.dart';
import 'package:ricker_app/screens/home_screen.dart';
import 'package:ricker_app/widgets/custom_button.dart';
import 'package:ricker_app/widgets/success_widget.dart';

class ChecklistFormSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('ChecklistFormSuccessScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist efetuada com sucesso!'),
        centerTitle: true,
        backgroundColor: CustomTheme.SUCCESS_COLOR,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SuccessWidget(),
          ),
        ),
      ),
      bottomNavigationBar: CustomButton(
        label: 'VOLTAR À TELA INICIAL',
        type: CustomButtonTypes.primary,
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            )
          );
        },
      ),
    );
  }
}
