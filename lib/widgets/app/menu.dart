import 'package:bapp/config/config.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/authentication/create_profile.dart';
import 'package:bapp/screens/authentication/login_screen.dart';
import 'package:bapp/screens/business/addbusiness/choose_category.dart';
import 'package:bapp/screens/settings/settings.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/widgets/tiles/theme_switcher.dart';
import 'package:event_bus/event_bus.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import 'bapp_navigator_widget.dart';

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
          automaticallyImplyLeading: false,
          title: Text("Menu"),
          actions: [
            IconButton(
              icon: Icon(FeatherIcons.xCircle),
              onPressed: () {
                BappNavigator.pop(context, null);
              },
            )
          ],
        ),
        body: Builder(
          builder: (
            _,
          ) {
            return Observer(
              builder: (_) {
                return ListView(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    ..._getMenuItems(context, []),
                    ThemeSwitcherTile(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _getMenuItems(BuildContext context, List<List<MenuItem>> items) {
    var ws = <Widget>[];
    items.forEach(
      (element) {
        element.forEach(
          (e) {
            ws.add(
              ListTile(
                title: Text(
                  e.name,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                trailing: Icon(e.icon),
                onTap: () {
                  _menuItemSelected(e.kind, context);
                },
              ),
            );
          },
        );
        ws.add(Divider());
      },
    );
    if (ws.isNotEmpty) ws.removeLast();
    return ws;
  }

  void _menuItemSelected(MenuItemKind kind, BuildContext context) {
    switch (kind) {
      case MenuItemKind.yourProfile:
        {
          BappNavigator.pushReplacement(context, CreateYourProfileScreen());
          break;
        }
      case MenuItemKind.settings:
        {
          BappNavigator.pushReplacement(context, SettingsScreen());
          break;
        }
      case MenuItemKind.rateTheApp:
        {
          BappNavigator.pushReplacement(context, SizedBox());
          break;
        }
      case MenuItemKind.helpUsImprove:
        {
          BappNavigator.pushReplacement(context, SizedBox());
          break;
        }
      case MenuItemKind.onBoardABusiness:
        {
          BappNavigator.pushReplacement(
              context,
              ChooseYourBusinessCategoryScreen(
                onBoard: true,
              ));
          break;
        }
      case MenuItemKind.logOut:
        {
          () async {
            await FirebaseAuth.instance.signOut();
            kBus.fire(AppEvents.reboot);
          }();
          break;
        }
      case MenuItemKind.logIn:
        {
          BappNavigator.pushReplacement(context, LoginScreen());
          break;
        }
      case MenuItemKind.switchTosShopping:
        {
          break;
        }
      case MenuItemKind.switchToBusiness:
        {
          break;
        }
      case MenuItemKind.switchToSales:
        {
          break;
        }
      case MenuItemKind.switchToManager:
        {
          break;
        }
      case MenuItemKind.switchToSudoUser:
        {
          break;
        }
    }
  }
}
