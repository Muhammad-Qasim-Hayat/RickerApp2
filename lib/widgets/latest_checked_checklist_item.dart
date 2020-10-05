import 'package:flutter/material.dart';
// import 'package:ricker_app/config/theme.dart';
import 'package:ricker_app/schemas/latest_checklist.dart';
import 'package:ricker_app/screens/checked_checklist_screen.dart';
import 'package:ricker_app/services/date_service.dart';
import 'package:ricker_app/utils/helper.dart';
import 'package:ricker_app/widgets/has_problem_widget.dart';

class LatestCheckedChecklistItem extends StatelessWidget {
  final LatestChecklist latestChecklist;

  const LatestCheckedChecklistItem(this.latestChecklist, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var stringDate = latestChecklist.finishedAt.toString();
    var humanDate = '${DateService.humanAbbrWeek(stringDate)} ${DateService.fullDate(stringDate)}';
    var type = Helper.getCheckedChecklistTypeForHumans(latestChecklist.type);

    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CheckedChecklistScreen(latestChecklist),
          )
        );
      },
      isThreeLine: true,
      title: Text(
        latestChecklist.vehicleName,
        style: Theme.of(context).textTheme.subtitle,
      ),
      trailing: Text(humanDate),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HasProblemWidget(latestChecklist.hasProblem=='true'?true:false),
          const SizedBox(height: 8.0,),
          Text(type),
        ],
      ),
    );
  }
}
