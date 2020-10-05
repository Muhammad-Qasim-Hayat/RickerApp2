import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:ricker_app/config/theme.dart';
// import 'package:fernendo_freelance_3/screens/login_screen.dart';
// import 'package:fernendo_freelance_3/screens/vehicle_screen.dart';
import 'package:ricker_app/services/auth_service.dart';
import 'package:ricker_app/services/http_service.dart';
import 'package:ricker_app/config/app.example.dart';
import 'package:ricker_app/services/vehicle_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpService.setTimeouts();
  HttpService.setBaseUrl(Config.BASE_URL);
  Intl.defaultLocale = Config.LOCALE;
  var home = await AuthService.getInitialWidget();

  await VehicleService.loadCurrentVehicle();

  runApp(MaterialApp(
    title: Config.APP_NAME,
    home: home,
    theme: ThemeData(
      primaryColor: CustomTheme.PRIMARY_COLOR,
      accentColor: CustomTheme.PRIMARY_COLOR,
    ),
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
  ));
}
