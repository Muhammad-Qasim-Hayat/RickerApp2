import 'package:flutter/material.dart';
import 'package:ricker_app/config/theme.dart';
import 'package:ricker_app/schemas/checklist_item_form_schema.dart';
import 'package:ricker_app/schemas/checklist_item_schema.dart';
import 'package:ricker_app/schemas/checklist_schema.dart';
import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/utils/helper.dart';

class ChecklistFormItemsList extends StatelessWidget {
  final Checklist checklist;
  final Function(ChecklistItem, ChecklistItemForm) onTap;

  const ChecklistFormItemsList({
    Key key,
    @required this.checklist,
    this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: checklist.items.length,
      itemBuilder: (context, index) {
        var checklistItem = checklist.items[index];
        var checklistItemForm = ChecklistService.getByChecklistItemId(checklistItem.id);
        var isOptional = checklistItem.optional;
        var isChecked = isOptional ? true : ChecklistService.isChecked(checklistItemForm);
        var hasProblem = isOptional ? true : ChecklistService.hasProblem(checklistItemForm);
        var photoStillRequired = ChecklistService.photoStillRequired(isOptional ? false : checklistItem.requiredPhoto, checklistItemForm);
        var hasPhotos = checklistItemForm != null ? checklistItemForm.images.length > 0 : false;
        var hasComments = checklistItemForm != null ? checklistItemForm.comments != null && checklistItemForm.comments.isNotEmpty : false;
        var photosCountText = photoStillRequired
          ? 'Foto obrigatória'
          : (checklistItemForm != null ? '${checklistItemForm.images.length} foto${checklistItemForm.images.length > 1 ? 's' : ''}' : '');
        var optionalText = isOptional
          ? 'Este item é opcional'
          : '';

        return ListTile(
          title: Text(Helper.strLimit(checklistItem.name)),
          isThreeLine: hasComments && (hasPhotos || photoStillRequired),
          subtitle: hasPhotos || photoStillRequired || hasComments || isOptional
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  isOptional && !hasPhotos && !hasComments
                    ? Text(
                        optionalText,
                        style: TextStyle(
                          color: CustomTheme.SUCCESS_COLOR,
                        ),
                      )
                    : const SizedBox(),
                  hasPhotos || photoStillRequired
                    ? Row(
                        children: <Widget>[
                          Icon(Icons.photo, color: Colors.grey),
                          const SizedBox(width: 4.0),
                          Text(photosCountText, style: TextStyle(color: photoStillRequired ? Colors.red : Colors.black54)),
                        ],
                      )
                    : const SizedBox(),
                  hasComments
                    ? Row(
                        children: <Widget>[
                          Icon(Icons.comment, color: Colors.grey),
                          const SizedBox(width: 4.0),
                          Text(
                            checklistItemForm.comments.replaceAll('\n', ' '),
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      )
                    : const SizedBox(),
                ],
              )
            : null,
          onTap: onTap == null ? null : () {
            onTap(checklistItem, checklistItemForm);
          },
          trailing: Icon(
            isChecked ? (hasProblem ? Icons.warning : Icons.done) : Icons.radio_button_unchecked,
            color: isChecked ? (hasProblem ? Colors.red : CustomTheme.SUCCESS_COLOR) : null,
          ),
        );
      },
    );
  }
}
