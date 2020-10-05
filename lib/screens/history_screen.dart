import 'package:flutter/material.dart';
import 'package:ricker_app/schemas/latest_checklist.dart';
import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/widgets/latest_checked_checklists_list.dart';
import 'package:ricker_app/widgets/try_again_button.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Future<List<LatestChecklist>> _future;
  var _items = <LatestChecklist>[];
  var _scrollController = ScrollController();
  var _fetching = false;
  var _totalItems = 0;
  var _totalPages = 1;
  var _currentPage = 1;
  var _error = false;

  @override
  void initState() {
    super.initState();
    _fetchData();

    _scrollController.addListener(() {
      var triggerFetchMoreSize = 0.9 * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > triggerFetchMoreSize && !_error) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    if (_currentPage > _totalPages || _fetching) {
      return;
    }

    setState(() {
      _fetching = true;
    });

    try {
      var response = await ChecklistService.getAllCheckedChecklists(
        page: _currentPage,
      );

      _items.addAll(response.data['docs'].map<LatestChecklist>((c) => LatestChecklist.fromJson(c)).toList());

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
  }

  @override
  Widget build(BuildContext context) {
    print('history');
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico'),
      ),
      body: LayoutBuilder(
        builder: (context, viewportConstraints) => SingleChildScrollView(
          controller: _scrollController,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight
            ),
            child: Column(
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
                          'Nenhuma checklist feita.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subhead,
                        ),
                      ),
                    )
                  : LatestCheckedChecklistList(_items),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    child: bottomWidget,
                  )
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}
