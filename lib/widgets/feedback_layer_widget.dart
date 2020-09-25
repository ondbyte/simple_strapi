import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FeedBackLayerWidget extends StatefulWidget {
  @override
  _FeedBackLayerWidgetState createState() => _FeedBackLayerWidgetState();
}

class _FeedBackLayerWidgetState extends State<FeedBackLayerWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red
        ),
      ),
    );
  }
}
