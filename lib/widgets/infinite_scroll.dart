import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:ricker_app/schemas/latest_checklist.dart';
import 'package:ricker_app/services/LocalDatabaseServices.dart';
import 'package:ricker_app/services/http_service.dart';
import 'package:ricker_app/utils/event_emitter.dart';
import 'package:ricker_app/widgets/try_again_button.dart';

class InfiniteScroll<T> extends StatefulWidget {
  final InfiniteScrollController controller;
  final String endpoint;
  final T Function(Map) fromJson;
  final Widget Function(T) renderItem;
  final String noItemsText;

  const InfiniteScroll({
    Key key,
    @required this.controller,
    @required this.endpoint,
    @required this.fromJson,
    @required this.renderItem,
    this.noItemsText = 'Nenhum item encontrado.',
  }) : super(key: key);

  @override
  _InfiniteScrollState<T> createState() => _InfiniteScrollState<T>();
}

class _InfiniteScrollState<T> extends State<InfiniteScroll<T>> {
  var _items=[];

  var _fetching = false;
  var _totalItems = 0;
  var _totalPages = 1;
  var _currentPage = 1;
  var _error = false;
  LocalDatabaseHandler databaseHandler=new LocalDatabaseHandler();

  @override
  void initState() {
    super.initState();
    _fetchData();

    widget.controller.addListener(() {
      var triggerFetchMoreSize = 0.9 * widget.controller.position.maxScrollExtent;

      if (widget.controller.position.pixels > triggerFetchMoreSize && !_error) {
        _fetchData();
      }
    });

    widget.controller.onRestart(([_]) {
      setState(() {
        _items = <T>[];
        _fetching = false;
        _totalItems = 0;
        _totalPages = 1;
        _currentPage = 1;
        _error = false;
        _fetchData();
      });
    });
  }

  Future<void> _fetchData() async {

    var connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi){
      if (_currentPage > _totalPages || _fetching) {
        return;
      }

      setState(() {
        _fetching = true;
      });

      try {
        var response = await HttpService.get('${widget.endpoint}?page=$_currentPage');

        _items.addAll(response.data['docs'].map<T>((c) => widget.fromJson(c)).toList());
        setState(() {
          _error = false;
          _totalItems = response.data['totalDocs'];
          _totalPages = response.data['totalPages'];
          _currentPage++;
        });
      } catch (e) {
        setState(() {
          _error = true;
        });
      } finally {
        setState(() {
          _fetching = false;
        });
      }

      if(widget.endpoint=="/checklists/checked"){
        List<LatestChecklist> list=[];
        _items.forEach((element) {
          if(element is LatestChecklist){
            list.add(element);
          }
        });
        databaseHandler.addHomepageData(list);
      }
    }
    else{
      setState(() {
        _fetching=true;
      });
      _items= await databaseHandler.getCheckList();

      setState(() {
        _fetching=false;
      });

    }






  }

  @override
  Widget build(BuildContext context) {
    Widget bottomWidget = Container();
    if (_fetching) {
      bottomWidget = CircularProgressIndicator();
    } else if (_error) {
      bottomWidget = TryAgainButton(
        onPressed: () {
          setState(() {
            _fetchData();
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: _items.isNotEmpty && !_fetching
        ? MainAxisAlignment.start
        : MainAxisAlignment.center,
      children: <Widget>[
        _items.isEmpty && !_fetching && !_error
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Center(
                child: Text(
                  widget.noItemsText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subhead,
                ),
              ),
            )
          : Ink(
              color: Colors.white,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      widget.renderItem(_items[index]),
                      Divider(height: 0.0),
                    ],
                  );
                },
              ),
            ),
          // : widget.renderItems(_items),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: bottomWidget,
          )
        ),
      ],
    );
  }
}

class InfiniteScrollController extends ScrollController {
  final _eventEmitter = EventEmitter();

  void onRestart(void Function([Object]) callback) {
    _eventEmitter.addListener('onRestart', callback);
  }

  void restart() {
    _eventEmitter.emit('onRestart');
  }

  @override
  void dispose() {
    _eventEmitter.removeAllListeners();
    super.dispose();
  }
}
