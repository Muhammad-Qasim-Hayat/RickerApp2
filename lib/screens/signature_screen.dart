import 'dart:io';

import 'package:flutter/material.dart';
import 'package:painter/painter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ricker_app/screens/checklist_form_preview_screen.dart';
import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/widgets/custom_button.dart';
import 'package:ricker_app/widgets/upload_widget.dart';

class SignatureScreen extends StatefulWidget {
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  PainterController _controller;
  bool _signatureSent = false;

  @override
  void initState() {
    super.initState();
    _initPaint();
  }

  void _initPaint() {
    _controller = PainterController()
      ..thickness = 5.0
      ..backgroundColor = Colors.white;

    _controller.addListener(() => setState(() {}));
  }

  Future<void> _finishPainting() async {
    PictureDetails picture;

    setState(() {
      picture = _controller.finish();
    });

    var tempDir = await getTemporaryDirectory();
    var file = File('${tempDir.path}/signature.png');
    file.writeAsBytesSync(await picture.toPNG());

    var filename = '${DateTime.now()}-signature.png';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: UploadWidget(
          url: '/checklists/signature',
          file: file,
          filename: filename,
          imageType: 'png',
          onUploadComplete: (response) async {
            ChecklistService.currentChecklistForm.signatureUrl = response.data['filename'];

            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ChecklistFormPreviewScreen(),
              ),
            );

            setState(() {
              _signatureSent = true;
            });
          },
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Signature Screen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Sua assinatura'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: _controller.isEmpty || _controller.isFinished() ? null : _controller.undo,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _controller.isEmpty ? null : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Tem certeza que deseja recomeçar?'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      textColor: Colors.grey,
                      child: Text('CANCELAR'),
                    ),
                    FlatButton(
                      onPressed: () {
                        if (_controller.isFinished()) {
                          setState(() {
                            _initPaint();
                          });
                        } else {
                          _controller.clear();
                        }

                        Navigator.of(context).pop();
                      },
                      textColor: Theme.of(context).primaryColor,
                      child: Text('LIMPAR'),
                    ),
                  ],
                )
              );
            },
          ),
        ],
      ),
      body: Painter(_controller),
      bottomNavigationBar: CustomButton(
        onPressed: _controller.isEmpty ? null : () {
          if (_signatureSent) {
             Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChecklistFormPreviewScreen(),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Sua assinatura está correta?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    textColor: Colors.grey,
                    child: Text('CANCELAR'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _finishPainting();
                    },
                    textColor: Theme.of(context).primaryColor,
                    child: Text('SIM'),
                  ),
                ],
              )
            );
          }
        },
        label: _signatureSent
          ? 'PROSSEGUIR'
          : 'ENVIAR ASSINATURA',
        type: CustomButtonTypes.primary,
      ),
    );
  }
}
