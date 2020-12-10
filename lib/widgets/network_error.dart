import 'package:bapp/main.dart';
import 'package:event_bus/event_bus.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AppEvents { reboot, unHandledError }

class BappEventsHandler extends StatefulWidget {
  final Widget child;
  final EventBus bus;

  const BappEventsHandler({Key key, this.child, this.bus}) : super(key: key);
  @override
  _BappEventsHandlerState createState() => _BappEventsHandlerState();
}

class _BappEventsHandlerState extends State<BappEventsHandler> {
  var _key = UniqueKey();

  @override
  void didChangeDependencies() {
    _listenForEvents(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }

  void _listenForEvents(BuildContext context) {
    widget.bus.on<AppEvents>().listen(
      (event) {
        switch (event) {
          case AppEvents.reboot:
            {
              setState(() {
                _key = UniqueKey();
              });
              break;
            }
          case AppEvents.unHandledError:
            {
              setState(() {
                _key = UniqueKey();
              });
              break;
            }
        }
      },
    );
  }
}

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
