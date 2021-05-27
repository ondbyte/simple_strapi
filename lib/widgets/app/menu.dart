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
import 'package:enum_to_string/enum_to_string.dart';
import 'package:event_bus/event_bus.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

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
            return Builder(
              builder: (_) {
                return ListView(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    _getSwitchRoleMenuItem(context),
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

  Widget _getSwitchRoleMenuItem(
    BuildContext context,
  ) {
    return Obx(
      () {
        var onTap;
        String title;
        final user = UserX.i.user();
        if (user is! User) {
          bPrint("noo user");
          return SizedBox();
        }
        if (user.alterEgoActivated ?? false) {
          onTap = () async {
            final updated = user.copyWIth(alterEgoActivated: false);
            final saved = await Users.update(updated);
            UserX.i.user(saved);
          };
          title = "Switch to customer";
        } else {
          onTap = () async {
            final updated = user.copyWIth(alterEgoActivated: true);
            final saved = await Users.update(updated);
            UserX.i.user(saved);
          };
          title = "Switch to business";
        }
        return Users.listenerWidget(
          strapiObject: user,
          builder: (_, user, loading) {
            return ListTile(
              title: Text(title),
              subtitle: loading ? LinearProgressIndicator() : null,
              onTap: onTap,
            );
          },
        );
      },
    );
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
            await fb.FirebaseAuth.instance.signOut();
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
