import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/constants.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/bapp_bar.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          flexibleSpace: BappBar(
            leading: "Menu",
            trailing: IconButton(
              icon: Icon(FeatherIcons.xCircle),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
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
                title: Text(e.name,style: Theme.of(context).textTheme.subtitle2,),
                trailing: Icon(e.icon),
                onTap: (){
                  _menuItemSelected(e.kind);
                },
              ),
            );
          },
        );
        ws.add(Divider());
      },
    );
    if(ws.isNotEmpty) ws.removeLast();
    return ws;
  }
  
  void _menuItemSelected(MenuItemKind kind){
    switch (kind){
      case MenuItemKind.yourProfile:{
        Navigator.of(context).pushNamed("/profilescreen");
        break;
      }
      case MenuItemKind.settings:{
        Navigator.of(context).pushNamed("/settingsscreen");
        break;
      }
      case MenuItemKind.rateTheApp:{
        Navigator.of(context).pushNamed("/ratemyappscreen");
        break;
      }
      case MenuItemKind.helpUsImprove:{
        Navigator.of(context).pushNamed("/improvescreen");
        break;
      }
      case MenuItemKind.referABusiness:{
        Navigator.of(context).pushNamed("/referbusinessscreen");
        break;
      }
      case MenuItemKind.logOut:{
        Provider.of<AuthStore>(context).signOut();
        break;
      }
      case MenuItemKind.logIn:{
        Navigator.of(context).pushNamed("/loginscreen");
        break;
      }
      case MenuItemKind.switchTosShopping:{
        Provider.of<CloudStore>(context).switchUserType();
        break;
      }
      case MenuItemKind.switchToBusiness:{
        Provider.of<CloudStore>(context).switchUserType();
        break;
      }
      case MenuItemKind.switchToSales:{
        Provider.of<CloudStore>(context).switchUserType();
        break;
      }
      case MenuItemKind.switchToManager:{
        Provider.of<CloudStore>(context).switchUserType();
        break;
      }
      case MenuItemKind.switchToSudoUser:{
        Provider.of<CloudStore>(context).switchUserType();
        break;
      }
    }
    Navigator.of(context).pop();
  }
}
