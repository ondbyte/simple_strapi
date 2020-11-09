import 'dart:io';

import 'package:bapp/FCM.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Settings"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ListTile(
                  title: Text("Notifications"),
                  subtitle: Text(
                    "If you wish to receive Bapp notifications please enable this",
                  ),
                  trailing: Switch(
                    onChanged: (b) async {
                      if (!BappFCM().isFcmInitialized) {
                        if (Platform.isIOS) {
                          final enabled = await BappFCM().initForIOS();
                          if (!enabled) {
                            Flushbar(
                              message:
                                  "Please authorize Bapp for notifications for better app experience",
                              duration: const Duration(seconds: 2),
                            ).show(context);
                          } else {
                            setState(() {});
                          }
                        }
                      }
                    },
                    value: BappFCM().isFcmInitialized,
                  ),
                ),
                ..._getDebugSettings()
              ]),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _getDebugSettings() {
    return kDebugMode
        ? [
            SizedBox(
              height: 20,
            ),
            Text("This is available only in debug mode"),
            SizedBox(
              height: 20,
            ),
            FlatButton(
                color: Colors.redAccent,
                onPressed: () {
                  nukeFirebase();
                },
                child: Text("Nuke firebase"))
          ]
        : [];
  }
}
