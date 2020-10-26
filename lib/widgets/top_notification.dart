import 'package:bapp/FCM.dart';
import 'package:flutter/material.dart';

class TopNotificationWidget extends StatefulWidget {
  TopNotificationWidget({Key key}) : super(key: key);

  @override
  _TopNotificationWidgetState createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<TopNotificationWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      kFCMListener = ({dynamic data, dynamic notif}) {
        print(data);
        print(notif);
      };
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(),
    );
  }
}
