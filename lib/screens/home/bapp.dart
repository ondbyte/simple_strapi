import 'package:bapp/stores/feedback_store.dart';
import 'package:bapp/widgets/feedback_layer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'customer_home.dart';

class Bapp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if("notbusiness"=="notbusiness")
          CustomerHome(),
        FeedBackLayerWidget()
      ],
    );
  }
}
