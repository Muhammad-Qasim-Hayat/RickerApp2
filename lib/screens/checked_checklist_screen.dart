import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:ricker_app/config/theme.dart';
import 'package:ricker_app/schemas/checked_checklist_schema.dart';
import 'package:ricker_app/schemas/checklist_form_schema.dart';
import 'package:ricker_app/schemas/latest_checklist.dart';
import 'package:ricker_app/services/LocalDatabaseServices.dart';
import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/utils/helper.dart';
import 'package:ricker_app/widgets/has_problem_widget.dart';
import 'package:ricker_app/widgets/thumbnail_image.dart';
import 'package:ricker_app/widgets/try_again_button.dart';

import '../schemas/checked_checklist_schema.dart';

class CheckedChecklistScreen extends StatefulWidget {
  final LatestChecklist latestChecklist;

  const CheckedChecklistScreen(this.latestChecklist, {Key key})
      : super(key: key);

  @override
  _CheckedChecklistScreenState createState() => _CheckedChecklistScreenState();
}

class _CheckedChecklistScreenState extends State<CheckedChecklistScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  LocalDatabaseHandler databaseHandler = new LocalDatabaseHandler();
  CheckedChecklist checkedChecklistentity;
  Future<CheckedChecklist> _future;
  bool loading=true;

  Future<void> _fetchData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {});
      {
        ///Now I have CheckedChecklist entity
        print("Internet available");
        _future = ChecklistService.getCheckedChecklist(
            widget.latestChecklist.id);
        databaseHandler.addToCheckedChecklist(await _future);
        checkedChecklistentity=await _future;
        checkedChecklistentity.printIt();
      }
      loading=false;

      setState(() {});
    } else {
      print("No internet");
      _future =
           databaseHandler.getCheckedChecklist(widget.latestChecklist.id);
      checkedChecklistentity=await _future;
      checkedChecklistentity.printIt();
      loading=false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    print('CheckedChecklistScreen');
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Checklist de ${widget.latestChecklist.vehicleName}'),
        ),
        body: loading?Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ):LayoutBuilder(
          builder: (context, viewportConstraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: FutureBuilder<CheckedChecklist>(
                  future: _future,
                  builder: (context, checkedEntity) {
                    if (checkedEntity.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (checkedEntity.hasError) {
                      return TryAgainButton(
                        onPressed: () {
                          setState(() {
                            _future = ChecklistService.getCheckedChecklist(
                                widget.latestChecklist.id);
                          });
                        },
                      );
                    }

                    var gridItems = <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Código',
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          Text(checkedEntity.data.sequentialNumber.toString()),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Problemas?',
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          HasProblemWidget(
                            widget.latestChecklist.hasProblem == 'true'
                                ? true
                                : false,
                            withProblemText: 'Sim',
                            withoutProblemText: 'Não',
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Veículo',
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          Text(
                              '${checkedEntity.data.vehicle.brand} ${checkedEntity.data.vehicle.name}'),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Placa',
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          Text(checkedEntity.data.vehicle.plate),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Localização',
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          InkWell(
                            onTap: () {
                              Helper.openUrl(Helper.getLocationURL(
                                  checkedEntity.data.lat,
                                  checkedEntity.data.lng));
                            },
                            child: Text(
                              '${checkedEntity.data.lat},${checkedEntity.data.lng}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Assinatura',
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          Expanded(
                            child:
                                ThumbnailImage(checkedEntity.data.signatureUrl),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Tipo',
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          Text(Helper.getCheckedChecklistTypeForHumans(
                              checkedEntity.data.type)),
                        ],
                      ),
                    ];

                    if (checkedEntity.data.type == ChecklistTypes.replacement) {
                      gridItems.add(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Substituição para',
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          Text(
                              '${checkedEntity.data.replacementUser.name} (${checkedEntity.data.replacementUser.registration})'),
                        ],
                      ));
                    }

                    gridItems.add(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Iniciada em',
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(checkedEntity.data.createdAt),
                      ],
                    ));

                    gridItems.add(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Finalizada em',
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(checkedEntity.data.finishedAt),
                      ],
                    ));

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Ink(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 0.0,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: gridItems,
                            ),
                          ),
                        ),
                        Divider(height: 0.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: checkedEntity.data.checkedItems.length,
                            itemBuilder: (context, index) {
                              var item = checkedEntity.data.checkedItems[index];

                              return ListTile(
                                title: Text(item.name),
                                // isThreeLine: true,
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.comment, color: Colors.grey),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          item.comments
                                                  ?.replaceAll('\n', ' ') ??
                                              'N/A',
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    item.images.length > 0
                                        ? GridView.count(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            crossAxisCount: 4,
                                            crossAxisSpacing: 8.0,
                                            mainAxisSpacing: 8.0,
                                            children: item.images
                                                .map<Widget>((url) =>
                                                    ThumbnailImage(url))
                                                .toList(),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                                trailing: Icon(
                                  item.hasProblem ? Icons.warning : Icons.done,
                                  color: item.hasProblem
                                      ? Colors.red
                                      : CustomTheme.SUCCESS_COLOR,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ));
  }
}
