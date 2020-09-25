import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PrimaryButton extends StatefulWidget {
  final Function onPressed;
  final Widget child;

  const PrimaryButton({Key key, this.onPressed, this.child}) : super(key: key);
  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Theme.of(context).primaryColor,
      onPressed: widget.onPressed,
      child: DefaultTextStyle(style: Theme.of(context).textTheme.button, child: widget.child),
    );
  }
}
