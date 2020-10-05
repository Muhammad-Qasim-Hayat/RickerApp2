import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:ricker_app/schemas/user_schema.dart';
import 'package:ricker_app/screens/initialization_error_screen.dart';
import 'package:ricker_app/screens/login_screen.dart';
import 'package:ricker_app/screens/vehicle_screen.dart';
import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/services/http_service.dart';
import 'package:ricker_app/services/storage_service.dart';

abstract class AuthService {
  static const String TOKEN_KEY = 'token';
  static User currentUser;

  static Future<Map> getCurrentUserFromAPI() async {
    var response = await HttpService.get('/me');

    return {'user': response.data['user'], 'token': response.data['token']};
  }

  static Future<String> getToken() async {
    return await StorageService.read(TOKEN_KEY);
  }

  static void setToken(String token) {
    StorageService.write(TOKEN_KEY, token);
    HttpService.setToken(token);
  }

  static void deleteToken() {
    StorageService.delete(TOKEN_KEY);
    HttpService.unsetToken();
  }

  static void setCurrentUser(Map user) {
    currentUser = User.fromJson(user);
  }

  static void unsetCurrentUser() {
    currentUser = null;
  }

  static Future<bool> check() async {
    String token = await getToken();

    if (token != null) {
      HttpService.setToken(token);

      var data = await getCurrentUserFromAPI();
      setCurrentUser(data['user']);
      setToken(data['token']);

      return true;
    }

    return false;
  }

  static Future<Widget> getInitialWidget() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        var authenticated = await check();

        if (authenticated) {
          return VehicleScreen();
        } else {
          return LoginScreen();
        }
      } on DioError catch (e) {
        if (e.type == DioErrorType.RESPONSE) {
          logout();
          return LoginScreen();
        } else {
          return InitializationErrorScreens();
        }
      }
    } else
      return VehicleScreen();
  }

  static Future<Map<String, dynamic>> attemptToAuthenticate(
      String registration, String password) async {
    var data = {
      'registration': registration,
      'password': password,
    };

    var response = await HttpService.post('/login', data: data);

    return {
      'user': response.data['user'],
      'token': response.data['token'],
    };
  }

  static Future<bool> authenticate(String registration, String password) async {
    try {
      var data = await attemptToAuthenticate(registration, password);
      setCurrentUser(data['user']);
      setToken(data['token']);

      return true;
    } on DioError catch (e) {
      if (e.type == DioErrorType.RESPONSE) {
        return false;
      } else {
        throw e;
      }
    }
  }

  static void logout() {
    deleteToken();
    unsetCurrentUser();
    ChecklistService.unsetCurrentChecklistAndChecklistForm();
    //TODO: Remove all data from local database
  }
}
