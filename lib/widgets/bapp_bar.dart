import 'package:flutter/material.dart';

class BappBar<T> extends StatelessWidget {
  final Color color;
  final T leading;

  const BappBar({Key key, this.color,this.leading}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color??Theme.of(context).backgroundColor,
      child: _getLeading(leading),
    );
  }

  Widget _getLeading(T widget){
    if(widget is String){
      return Text(widget);
    }
    if(widget is Text){
      return widget;
    }
    if(widget )
  }
}
