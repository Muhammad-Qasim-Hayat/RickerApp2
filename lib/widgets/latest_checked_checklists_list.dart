import 'package:flutter/material.dart';
import 'package:ricker_app/schemas/latest_checklist.dart';
import 'package:ricker_app/widgets/latest_checked_checklist_item.dart';

class LatestCheckedChecklistList extends StatelessWidget {
  final List<LatestChecklist> items;
  final ScrollController controller;

  const LatestCheckedChecklistList(this.items, {Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: Colors.white,
      child: ListView.builder(
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              LatestCheckedChecklistItem(items[index]),
              Divider(height: 0.0),
            ],
          );
        },
      ),
    );
  }
}
