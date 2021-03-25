import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PrimaryButton extends StatefulWidget {
  final Function()? onPressed;
  final String data;
  final bool hide;
  final bool fullWidth;

  const PrimaryButton(this.data,
      {Key? key, this.onPressed, this.hide = false, this.fullWidth = true})
      : super(key: key);
  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return !widget.hide
        ? FlatButton(
            minWidth: widget.fullWidth ? double.maxFinite : double.minPositive,
            disabledColor: Theme.of(context).disabledColor,
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
                  ?.apply(color: Colors.white),
            ),
          )
        : SizedBox();
  }
}
