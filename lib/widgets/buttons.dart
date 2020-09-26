import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PrimaryButton extends StatefulWidget {
  final Function onPressed;
  final String data;
  final bool hide;

  const PrimaryButton(this.data, {Key key, @required this.onPressed, this.hide = false})
      : super(key: key);
  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 41,
      child: !widget.hide
          ? FlatButton(
              color: Theme.of(context).primaryColor,
              onPressed: widget.onPressed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.data,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .apply(color: Theme.of(context).primaryColorLight),
              ),
            )
          : SizedBox(),
    );
  }
}
