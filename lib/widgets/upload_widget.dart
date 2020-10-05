import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ricker_app/services/http_service.dart';
import 'package:ricker_app/utils/constants.dart';
import 'package:ricker_app/utils/helper.dart';

class UploadWidget extends StatefulWidget {
  final String url;
  final File file;
  final String filename;
  final String imageType;
  final Map data;
  final Function(Response) onUploadComplete;
  final Function onUploadError;

  const UploadWidget({
    Key key,
    @required this.url,
    @required this.file,
    @required this.filename,
    @required this.imageType,
    this.data,
    this.onUploadComplete,
    this.onUploadError,
  }) : super(key: key);

  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  var _progress = Helper.getUploadProgress(0);
  var _error = false;

  @override
  void initState() {
    super.initState();
    _startUploading();
  }

  Future<void> _startUploading() async {
    setState(() {
      _error = false;
    });

    try {
      var response = await HttpService.upload(
        widget.url,
        widget.file,
        widget.filename,
        imageType: widget.imageType,
        data: widget.data ?? const {},
        onSendProgress: _onSendProgress,
      );

      if (widget.onUploadComplete != null) {
        widget.onUploadComplete(response);
      }
    } catch (e) {
      print(e);

      setState(() {
        _error = true;
      });

      if (widget.onUploadError != null) {
        widget.onUploadError();
      }
    }
  }

  void _onSendProgress(int count, int total) {
    setState(() {
      _progress = Helper.getUploadProgress(total, count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: !_error
        ? Text(
            'Enviando ${_progress.formattedPercentSent}',
            textAlign: TextAlign.center,
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.warning, color: Colors.red, size: 32.0,),
              const SizedBox(width: 8.0),
              Expanded(
                child: const Text(
                  NETWORK_ERROR_MESSAGE,
                  style: TextStyle(
                    color: Colors.red,
                  )
                ),
              )
            ],
          ),
      content: !_error
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
            ]
          )
        : const SizedBox(),
      actions: _error
        ? <Widget>[
            FlatButton(
              child: Text('CANCELAR'),
              textColor: Colors.black54,
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('TENTAR NOVAMENTE'),
              textColor: Theme.of(context).primaryColor,
              onPressed: _startUploading,
            )
          ]
        : <Widget>[],
    );
  }
}
