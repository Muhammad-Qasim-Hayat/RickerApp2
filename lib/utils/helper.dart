import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ricker_app/config/app.example.dart';
import 'package:ricker_app/config/theme.dart';
import 'package:ricker_app/schemas/checklist_form_schema.dart';
import 'package:ricker_app/schemas/upload_progress_schema.dart';
import 'package:path/path.dart';
import 'package:ricker_app/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class Helper {
  static String strLimit(String str, [int length = 60]) {
    if (str.length > length) {
      return str.trim().substring(0, length) + '...';
    }

    return str;
  }

  static String fileSizeAbbr(int bytes) {
    int rounded = bytes.round();

    if (bytes >= 1000000000) {
      return '${(rounded / 1e+9).toStringAsFixed(2)} GB';
    } else if (bytes >= 1000000) {
      return '${(rounded / 1e+6).toStringAsFixed(2)} MB';
    } else if (bytes >= 1000) {
      return '${(rounded / 1e+3).toStringAsFixed(2)} kB';
    }

    return '$rounded B';
  }

  static UploadProgress getUploadProgress(int bytesTotal, [int bytesSent = 0, int bytesReceived = 0]) {
    var percentSent = (bytesSent / bytesTotal) * 100;
    var formattedTotal = fileSizeAbbr(bytesTotal);
    var formattedReceived = fileSizeAbbr(bytesReceived);
    var formattedSent = fileSizeAbbr(bytesSent);

    if (percentSent.isNaN) {
      percentSent = 0.0;
    }

    var formattedPercentSent = '${percentSent.round()}%';

    return UploadProgress(
      bytesSent,
      bytesTotal,
      bytesReceived,
      percentSent,
      formattedSent: formattedSent,
      formattedTotal: formattedTotal,
      formattedReceived: formattedReceived,
      formattedPercentSent: formattedPercentSent,
    );
  }

  static String getUploadedFileURL(String filename) {
    return '${Config.BASE_URL}/uploads/$filename';
  }

  static String getUploadedFileThumbnailURL(String filename) {
    var url = getUploadedFileURL(filename);
    var ext = extension(url);
    var newUrl = url.replaceFirst(ext, '_thumbnail$ext');
    return newUrl;
  }

  static T getEnumFromString<T>(List<T> values, String value) {
    return values.firstWhere((r) => describeEnum(r) == value, orElse: () => null);
  }

  static void showSnackbar(GlobalKey<ScaffoldState> _scaffoldKey, String text, {Color color = CustomTheme.SUCCESS_COLOR, Duration duration = const Duration(seconds: 3)}) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        duration: duration,
      )
    );
  }

  static void showError(GlobalKey<ScaffoldState> _scaffoldKey, String text, {Duration duration = const Duration(seconds: 3)}) {
    showSnackbar(_scaffoldKey, text, color: Colors.red, duration: duration);
  }

  static void showNetworkError(GlobalKey<ScaffoldState> _scaffoldKey) {
    showError(_scaffoldKey, NETWORK_ERROR_MESSAGE);
  }

  static void showLoadingDialog(BuildContext context, {bool popLast = false}) {
    if (popLast) {
      Navigator.of(context).pop();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      )
    );
  }

  static String getCheckedChecklistTypeForHumans(ChecklistTypes type) {
    switch (type) {
      case ChecklistTypes.daily:
        return 'Diária';
      case ChecklistTypes.monthly:
        return 'Mensal';
      default:
        return 'Substituição';
    }
  }

  static Future<void> openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static String getLocationURL(double lat, double lng) {
    return 'https://openstreetmap.org/?mlat=$lat&mlon=$lng&zoom=16&layers=M';
  }
}
