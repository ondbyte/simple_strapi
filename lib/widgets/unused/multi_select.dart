import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultiSelect<T> extends StatefulWidget {
  final List<T> options;
  final Function(List<T>)? onChanged;
  final String Function(T) titleForThis, subTitleForThis;

  const MultiSelect({
    Key? key,
    this.onChanged,
    this.options = const [],
    required this.titleForThis,
    required this.subTitleForThis,
  }) : super(key: key);
  @override
  _MultiSelectState createState() => _MultiSelectState();
}

class _MultiSelectState<T> extends State<MultiSelect<T>> {
  final _selectedList = <T>[];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.options.length,
      itemBuilder: (_, i) {
        return Selector(
          title: () {
            return widget.titleForThis(widget.options[i]);
          },
          subTitle: () {
            return widget.subTitleForThis(widget.options[i]);
          },
          onSelected: (b) {
            if (b) {
              _selectedList.remove(widget.options[i]);
            } else {
              _selectedList.add(widget.options[i]);
            }
            widget.onChanged?.call(_selectedList);
          },
        );
      },
    );
  }
}

class Selector extends StatefulWidget {
  final Function(bool) onSelected;
  final String Function() title, subTitle;

  const Selector(
      {Key? key,
      required this.onSelected,
      required this.title,
      required this.subTitle})
      : super(key: key);
  @override
  _SelectorState createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  bool _selected = false;
  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      textColor: Theme.of(context).indicatorColor,
      selectedColor: Colors.white,
      selectedTileColor: Theme.of(context).primaryColor,
      child: ListTile(
        title: Text(widget.title()),
        subtitle: Text(widget.subTitle()),
        selected: _selected,
        onTap: () {
          setState(() {
            _selected = !_selected;
            widget.onSelected(_selected);
          });
        },
      ),
    );
  }
}
