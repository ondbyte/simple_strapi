
import 'package:bapp/widgets/app/bapp_themed_app.dart';
import 'package:flutter/material.dart';

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
        value: BappThemedApp.isDarkTheme(context),
        onChanged: (b) {
          setState(() {
            BappThemedApp.switchTheme(context);
          });
        },
      ),
    );
  }
}
