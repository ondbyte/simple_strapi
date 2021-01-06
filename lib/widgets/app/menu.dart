import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/authentication/create_profile.dart';
import 'package:bapp/screens/authentication/login_screen.dart';
import 'package:bapp/screens/business/addbusiness/choose_category.dart';
import 'package:bapp/screens/settings/settings.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/tiles/theme_switcher.dart';
import 'package:event_bus/event_bus.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
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
        body: Consumer<CloudStore>(
          builder: (_, cloudStore, __) {
            return Observer(
              builder: (_) {
                final bappUser = cloudStore.bappUser;
                final items = Helper.filterMenuItems(
                  bappUser.userType.value,
                  bappUser.alterEgo.value,
                  cloudStore.status,
                );
                return ListView(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    ..._getMenuItems(context, items),
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
          BappNavigator.pushReplacement(context, ChooseYourBusinessCategoryScreen(onBoard: true,));
          break;
        }
      case MenuItemKind.logOut:
        {
          () async {
            await Provider.of<CloudStore>(context, listen: false).signOut();
            Provider.of<EventBus>(context, listen: false)
                .fire(AppEvents.reboot);
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
          Provider.of<CloudStore>(context, listen: false)
              .switchUserType(context);
          break;
        }
      case MenuItemKind.switchToBusiness:
        {
          Provider.of<CloudStore>(context, listen: false)
              .switchUserType(context);
          break;
        }
      case MenuItemKind.switchToSales:
        {
          Provider.of<CloudStore>(context, listen: false)
              .switchUserType(context);
          break;
        }
      case MenuItemKind.switchToManager:
        {
          Provider.of<CloudStore>(context, listen: false)
              .switchUserType(context);
          break;
        }
      case MenuItemKind.switchToSudoUser:
        {
          Provider.of<CloudStore>(context, listen: false)
              .switchUserType(context);
          break;
        }
    }
  }
}
