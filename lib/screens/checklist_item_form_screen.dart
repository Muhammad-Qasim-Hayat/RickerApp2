import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:ricker_app/config/theme.dart';
import 'package:ricker_app/schemas/checklist_item_form_schema.dart';
import 'package:ricker_app/schemas/checklist_item_schema.dart';
import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/utils/debouncer.dart';
import 'package:ricker_app/utils/helper.dart';
import 'package:ricker_app/widgets/custom_button.dart';
import 'package:ricker_app/widgets/custom_text_field.dart';
import 'package:ricker_app/widgets/thumbnail_image.dart';
import 'package:ricker_app/widgets/try_again_button.dart';
import 'package:ricker_app/widgets/upload_widget.dart';

class ChecklistItemFormScreen extends StatefulWidget {
  final ChecklistItem checklistItem;
  final ChecklistItemForm checklistItemForm;

  const ChecklistItemFormScreen({
    Key key,
    @required this.checklistItem,
    @required this.checklistItemForm,
  }) : super(key: key);

  @override
  _ChecklistFormScreenState createState() => _ChecklistFormScreenState();
}

class _ChecklistFormScreenState extends State<ChecklistItemFormScreen> {
  final _commentsController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _debouncer = Debouncer();
  Future<void> _future;
  ChecklistItemForm _checklistItemForm;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _future = _fetchChecklistItemForm();
  }

  Future<void> _openCamera() async {
    var file = await ImagePicker.pickImage(source: ImageSource.camera);
    _uploadPhoto(file);
  }

  Future<void> _uploadPhoto(File file) async {
    if (file != null) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: UploadWidget(
                  url: '/checklists/photo',
                  file: file,
                  filename: path.basename(file.path),
                  imageType: 'png',
                  data: {
                    'itemId': _checklistItemForm.itemId,
                  },
                  onUploadComplete: (response) {
                    Navigator.of(context).pop();

                    setState(() {
                      _checklistItemForm.images.add(response.data['filename']);
                    });
                  },
                ),
              ));
    }
  }

  Future<void> _fetchChecklistItemForm() async {
    _checklistItemForm = widget.checklistItemForm;

    if (_checklistItemForm == null) {
      _checklistItemForm = await ChecklistService.checkItem(
          widget.checklistItem.id,
          hasProblem: widget.checklistItem.optional ? true : null);
      ChecklistService.currentChecklistForm.items.add(_checklistItemForm);
    }

    _commentsController.text = _checklistItemForm.comments;
  }

  Future<void> _onImageDelete(String filename) async {
    setState(() {
      _submitting = true;
    });

    try {
      await ChecklistService.deleteItemImage(
          _checklistItemForm.itemId, filename);

      setState(() {
        _checklistItemForm.images.removeWhere((i) => i == filename);
      });
    } catch (e) {
      Helper.showNetworkError(_scaffoldKey);
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }

  Future<void> _updateCheckedItem(String comments, bool hasProblem) async {
    print('update checklist item');

    var lastComments = _checklistItemForm.comments;
    var lastHasProblem = _checklistItemForm.hasProblem;

    setState(() {
      _submitting = true;
      _checklistItemForm.comments = comments;
      _checklistItemForm.hasProblem = hasProblem;
    });

    try {
      await ChecklistService.checkItem(widget.checklistItem.id,
          comments: comments, hasProblem: hasProblem);
    } catch (e) {
      Helper.showNetworkError(_scaffoldKey);
      setState(() {
        _checklistItemForm.comments = lastComments;
        _checklistItemForm.hasProblem = lastHasProblem;
        _commentsController.text = lastComments;
      });
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("checklist item form screen");
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: !_submitting
              ? Text(widget.checklistItem.name)
              : const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.0,
                  )),
        ),
        body: LayoutBuilder(
          builder: (context, viewportConstraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: FutureBuilder<void>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return TryAgainButton(
                        onPressed: () {
                          setState(() {
                            _future = _fetchChecklistItemForm();
                          });
                        },
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          widget.checklistItem.name,
                          style: Theme.of(context).textTheme.title,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                            height: _checklistItemForm.optional ||
                                    ChecklistService.photoStillRequired(
                                        widget.checklistItem.optional
                                            ? false
                                            : widget
                                                .checklistItem.requiredPhoto,
                                        widget.checklistItemForm)
                                ? 8.0
                                : 0.0),
                        _checklistItemForm.optional
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child: Text(
                                  'Este item é opcional.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subhead
                                      .copyWith(
                                          color: CustomTheme.SUCCESS_COLOR),
                                  textAlign: TextAlign.center,
                                ))
                            : const SizedBox(),
                        ChecklistService.photoStillRequired(
                                widget.checklistItem.optional
                                    ? false
                                    : widget.checklistItem.requiredPhoto,
                                widget.checklistItemForm)
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child: Text(
                                  'Pelo menos uma foto é obrigatória para este item.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subhead
                                      .copyWith(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ))
                            : const SizedBox(),
                        const SizedBox(height: 32.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IgnorePointer(
                                ignoring: _checklistItemForm.optional ||
                                    (_checklistItemForm.hasProblem != null &&
                                        _checklistItemForm.hasProblem),
                                child: CustomButton(
                                  label: 'SIM',
                                  onPressed: () {
                                    _updateCheckedItem(
                                        _checklistItemForm.comments, true);
                                  },
                                  type: _checklistItemForm.optional ||
                                          (_checklistItemForm.hasProblem !=
                                                  null &&
                                              _checklistItemForm.hasProblem)
                                      ? CustomButtonTypes.primary
                                      : CustomButtonTypes.primaryLight,
                                )),
                            const SizedBox(width: 8.0),
                            IgnorePointer(
                              ignoring: _checklistItemForm.optional ||
                                  (_checklistItemForm.hasProblem != null &&
                                      !_checklistItemForm.hasProblem),
                              child: CustomButton(
                                label: 'NÃO',
                                onPressed: () {
                                  _updateCheckedItem(
                                      _checklistItemForm.comments, false);
                                },
                                type: _checklistItemForm.hasProblem != null &&
                                        !_checklistItemForm.hasProblem
                                    ? CustomButtonTypes.primary
                                    : CustomButtonTypes.primaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32.0),
                        CustomTextField(
                          controller: _commentsController,
                          label: 'Observações',
                          onChanged: (value) {
                            _debouncer(() => _updateCheckedItem(
                                value, _checklistItemForm.hasProblem));
                          },
                          maxLines: null,
                        ),
                        const SizedBox(height: 8.0),
                        GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: <Widget>[
                            for (var imageUrl in _checklistItemForm.images)
                              ThumbnailImage(imageUrl,
                                  onDelete: _onImageDelete),
                            Material(
                                color: CustomTheme.PRIMARY_COLOR,
                                child: Ink(
                                  child: InkWell(
                                    onTap: () {
                                      _openCamera();
                                    },
                                    child: Center(
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 48.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ));
  }
}
