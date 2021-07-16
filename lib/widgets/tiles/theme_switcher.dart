import 'package:bapp/super_strapi/my_strapi/persistenceX.dart';
import 'package:bapp/widgets/app/bapp_themed_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yadunandans_flutter_helpers/themed_app.dart';

class ThemeSwitcherTile extends StatefulWidget {
  @override
  _ThemeSwitcherTileState createState() => _ThemeSwitcherTileState();
}

class _ThemeSwitcherTileState extends State<ThemeSwitcherTile> {
  var _dark = false;

  @override
  void initState() {
    PersistenceX.i
        .getValue(
      "dark",
      defaultValue: ThemeMode.system == ThemeMode.dark,
    )
        .then(
      (value) {
        setState(() {
          _dark = value;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Dark mode"),
      trailing: Switch(
        value: _dark,
        onChanged: (b) {
          Get.changeThemeMode(b ? ThemeMode.dark : ThemeMode.light);
          PersistenceX.i.saveValue("dark", b);
          setState(() {
            _dark = b;
          });
        },
      ),
    );
  }
}
