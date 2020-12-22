import 'package:bapp/helpers/extensions.dart';
import 'package:flutter/material.dart';

class CancellationCinfirmDialog extends StatefulWidget {
  final String title,message;

  const CancellationCinfirmDialog({Key key, this.title, this.message,}) : super(key: key);
  @override
  _CancellationCinfirmDialogState createState() => _CancellationCinfirmDialogState();
}

class _CancellationCinfirmDialogState extends State<CancellationCinfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Text(widget.message),
      actions: [
        FlatButton(
          child: Text("Yes"),
          onPressed: (){
            BappNavigator.pop(context, true);
          },
        ),
        FlatButton(
          child: Text("No"),
          onPressed: (){
            BappNavigator.pop(context, false)
          },
        ),
      ],
    );
  }
}

