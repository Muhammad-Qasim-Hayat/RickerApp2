import 'package:flutter/material.dart';
import 'package:ricker_app/widgets/custom_searchable_dialog.dart';
import 'package:ricker_app/widgets/custom_text_field.dart';

class CustomSearchableItem<T> {
  final String label;
  final T value;

  CustomSearchableItem({
    @required this.label,
    @required this.value,
  });

  @override
  String toString() => 'CustomSearchableItem(label: $label, value: $value)';
}

class CustomSearchable<T> extends StatefulWidget {
  final TextEditingController controller;
  final Function(CustomSearchableItem<T>) onChanged;
  final CustomSearchableItem<T> value;
  final List<CustomSearchableItem<T>> items;
  final String label;
  final String hintText;
  final String searchHint;
  final bool enabled;

  CustomSearchable({
    Key key,
    @required this.controller,
    @required this.onChanged,
    @required this.value,
    @required this.items,
    @required this.label,
    this.hintText = 'Selecione',
    this.searchHint = 'Pesquisar',
    this.enabled = true,
  }) : super(key: key);

  @override
  _CustomSearchableState createState() => _CustomSearchableState<T>();
}

class _CustomSearchableState<T> extends State<CustomSearchable<T>> {
  @override
  Widget build(BuildContext context) {
    if (widget.value == null) {
      widget.controller.clear();
    }

    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      enabled: widget.enabled,
      readonly: true,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            contentPadding: const EdgeInsets.all(0.0),
            children: <Widget>[
              CustomSearchableDialog<T>(
                items: widget.items,
                onChanged: (v) {
                  widget.onChanged(v);
                  Navigator.of(context).pop();
                },
                searchHint: widget.searchHint,
              ),
            ],
            // actions: <Widget>[
            //   FlatButton(
            //     onPressed: Navigator.of(context).pop,
            //     textColor: Colors.grey,
            //     child: Text('FECHAR'),
            //   ),
            // ],
          )
        );
      },
    );
    // return Container(
    //   height: 50.0,
    //   // padding: const EdgeInsets.all(0.0),
    //   decoration: BoxDecoration(
    //     border: Border.all(width: 1.5, color: Theme.of(context).primaryColor)
    //   ),
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       // SearchableDropdown.single(
    //       //   hint: hint,
    //       //   searchHint: searchHint,
    //       //   closeButton: 'Fechar',
    //       //   underline: Container(),
    //       //   onChanged: onChanged,
    //       //   value: value,
    //       //   isExpanded: true,
    //       //   items: items,
    //       // ),
    //     ],
    //   ),
    // );
  }
}
