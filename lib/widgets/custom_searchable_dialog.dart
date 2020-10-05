import 'package:flutter/material.dart';
import 'package:ricker_app/widgets/custom_searchable.dart';

class CustomSearchableDialog<T> extends StatefulWidget {
  final Function(CustomSearchableItem<T>) onChanged;
  final List<CustomSearchableItem<T>> items;
  final String searchHint;

  const CustomSearchableDialog({
    Key key,
    @required this.onChanged,
    @required this.items,
    @required this.searchHint,
  }) : super(key: key);

  @override
  _CustomSearchableDialogState createState() => _CustomSearchableDialogState<T>();
}

class _CustomSearchableDialogState<T> extends State<CustomSearchableDialog<T>> {
  var _searched = <CustomSearchableItem<T>>[];

  @override
  void initState() {
    super.initState();
    _searched = [...widget.items];
  }

  void _search(String value) {
    var result = widget.items.where((item) =>
      item.label.toLowerCase().contains(value.toLowerCase())).toList();

    _searched.clear();

    setState(() {
      _searched = [...result];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
          child: Text(widget.searchHint),
        ),
        const SizedBox(height: 8.0,),
        TextField(
          onChanged: _search,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16.0),
            prefixIcon: Icon(Icons.search),
            filled: false, fillColor: Colors.red
          ),
        ),
        // Stack(
          // children: <Widget>[
            Container(
              width: double.maxFinite,
              height: 200.0,
              child: ListView.builder(
                itemCount: _searched.length,
                itemBuilder: (context, index) => InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_searched[index].label),
                  ),
                  onTap: () {
                    widget.onChanged(_searched[index]);
                  },
                ),
                shrinkWrap: true,
              ),
            ),
            // Positioned.fill(
            //   child: Align(
            //     alignment: Alignment.bottomCenter,
            //     child: FlatButton(
            //       onPressed: Navigator.of(context).pop,
            //       textColor: Colors.grey,
            //       child: Text('FECHAR'),
            //     ),
            //   ),
            // )
          // ],
        // ),
      ],
    );
  }
}
