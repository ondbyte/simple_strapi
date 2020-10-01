import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/location_label.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import 'store_provider.dart';

class BappBar<T> extends PreferredSize {
  final Color color;
  final T leading;
  final BappBarLeadingSize size;
  final Widget trailing;

  const BappBar(
      {Key key,
      this.color,
      this.leading,
      this.size = BappBarLeadingSize.big,this.trailing})
      : super(key: key,);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 16),
        height: Scaffold.of(context).appBarMaxHeight,
        color: color ?? Theme.of(context).backgroundColor,
        child: DefaultTextStyle(
          style: _getSize(size, context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _getLeading(leading),
              if (trailing!=null)
                trailing,
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _getSize(BappBarLeadingSize s, BuildContext context) {
    switch (s) {
      case BappBarLeadingSize.normal:
        {
          return Theme.of(context).textTheme.headline3;
        }
      case BappBarLeadingSize.small:
        {
          return Theme.of(context).textTheme.subtitle1;
        }
      //or big
      default:
        {
          return Theme.of(context).textTheme.headline1;
        }
    }
  }

  Widget _getLeading(T data) {
    if (data is String) {
      return Text(data);
    }
    if (data is Text) {
      return data;
    }
    if (data is LocationLabelWidget) {
      return data;
    }
    return SizedBox();
  }
}

enum BappBarLeadingSize { small, normal, big }
