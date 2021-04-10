import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FailedStrapiResponse extends StatelessWidget {
  final String message;
  const FailedStrapiResponse({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.shade100,
      alignment: Alignment.center,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      child: Text(
        "$message",
        style: TextStyle(
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
