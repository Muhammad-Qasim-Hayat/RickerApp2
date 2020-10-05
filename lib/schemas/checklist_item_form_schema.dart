import 'package:flutter/foundation.dart';

class ChecklistItemForm {
  final String itemId;
  final bool optional;
  bool hasProblem;
  String comments;
  List<String> images;

  ChecklistItemForm({
    @required this.itemId,
    @required this.optional,
    @required this.hasProblem,
    this.comments,
    this.images,
  });

  ChecklistItemForm.fromJson(Map json)
    : itemId = json['itemId'],
      optional = json['optional'],
      hasProblem = json['optional'] ? true : json['hasProblem'],
      comments = json['comments'],
      images = json['images'].map<String>((i) => i.toString()).toList();

  @override
  String toString() {
    return 'ChecklistItemForm(itemId: $itemId, optional: $optional, hasProblem: $hasProblem, comments: $comments, images: $images)';
  }
}
