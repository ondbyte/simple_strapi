
import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.network_check),
          SizedBox(
            height: 20,
          ),
          Text("Please check your networ"),
          SizedBox(
            height: 20,
          ),
          FlatButton(
            onPressed: () {
              Provider.of<EventBus>(context, listen: false)
                  .fire(AppEvents.reboot);
            },
            child: Text("Try again"),
          )
        ],
      ),
    );
  }
}