import 'package:flutter/material.dart';

class ErrorTile extends StatefulWidget {
  final String message;
  ErrorTile({Key? key, required this.message}) : super(key: key);

  @override
  _ErrorTileState createState() => _ErrorTileState();
}

class _ErrorTileState extends State<ErrorTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Text(
        widget.message,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
