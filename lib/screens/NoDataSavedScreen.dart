import 'package:flutter/material.dart';
import 'package:ricker_app/screens/vehicle_screen.dart';
import 'package:ricker_app/widgets/custom_button.dart';

class NoDataScreen extends StatefulWidget {
  @override
  _NoDataScreenState createState() => _NoDataScreenState();
}

class _NoDataScreenState extends State<NoDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Text(
              "No hay datos locales para los criterios dados\nenciende internet y vuelve a intentarlo",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).primaryColor
              ),
            ),

            SizedBox(
              height: 20,
            ),

            CustomButton(
              label: "Go back",
              onPressed: (){
                Navigator.of(context).pop();
              },
              type: CustomButtonTypes.primary,
            ),
          ],

        ),
      ),

    );
  }
}
