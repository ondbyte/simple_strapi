import 'package:bapp/widgets/feedback_layer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Bapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FeedBackLayerWidget()
      ],
    );
  }
}
