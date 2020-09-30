import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/constants.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Scaffold(
        appBar: AppBar(
          leading: SizedBox(),
          title: Text("Menu"),
          actions: [
            IconButton(
              icon: Icon(FeatherIcons.xCircle),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            ..._getMenuItems()
          ],
        ),
      ),
    );
  }

  List<Widget> _getMenuItems() {
    var ws = <Widget>[];
    kFilteredMenuItems.forEach(
      (element) {
        element.forEach(
          (e) {
            ws.add(
              ListTile(
                title: Text(e.name),
                trailing: Icon(e.icon),
              ),
            );
          },
        );
        ws.add(Divider());
      },
    );
    return ws;
  }
}
