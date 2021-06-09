import 'package:bapp/widgets/app/bapp_themed_app.dart';
import 'package:flutter/material.dart';
import 'package:yadunandans_flutter_helpers/themed_app.dart';

class ThemeSwitcherTile extends StatefulWidget {
  @override
  _ThemeSwitcherTileState createState() => _ThemeSwitcherTileState();
}

class _ThemeSwitcherTileState extends State<ThemeSwitcherTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Dark mode"),
      trailing: Switch(
        value: ThemedApp.isDark(context),
        onChanged: (b) {
          setState(() {
            if (b) {
              ThemedApp.darken(context);
            } else {
              ThemedApp.lighten(context);
            }
          });
        },
      ),
    );
  }
}
