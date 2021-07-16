import 'package:bapp/config/config.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/authentication/create_profile.dart';
import 'package:bapp/screens/authentication/email_login_screen.dart';
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
import 'package:get/get.dart';

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
                Get.back();
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
                    _getLogoutTile(context),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _getLogoutTile(BuildContext context) {
    return Obx(() {
      final user = UserX.i.user();
      if (user is! User) {
        return ListTile(
          title: Text("Login"),
          onTap: () {
            Get.to(LoginScreen());
          },
        );
      } else {
        return ListTile(
          title: Text("Logout"),
          onTap: () async {
            await UserX.i.logout();
          },
        );
      }
    });
  }

  Widget _getSwitchRoleMenuItem(
    BuildContext context,
  ) {
    return Obx(
      () {
        var onTap;
        late String title;
        final user = UserX.i.user();
        if (user is! User) {
          return ListTile(
            title: Text("Switch to business"),
            onTap: () async {
              final response = await Get.to(EmailLoginScreen());
              if (user is User) {
                Get.back();
              }
            },
          );
        } else if (user.authenticatedUserType ==
            AuthenticatedUserType.phoneBusinessSide) {
          onTap = () async {
            final updated = user.copyWIth(
                authenticatedUserType: AuthenticatedUserType.phoneCustomerSide);
            final saved = await Users.update(updated);
            UserX.i.user(saved);
          };
          title = "Switch to customer";
        } else if (user.authenticatedUserType ==
            AuthenticatedUserType.phoneCustomerSide) {
          onTap = () async {
            final updated = user.copyWIth(
                authenticatedUserType: AuthenticatedUserType.phoneBusinessSide);
            final saved = await Users.update(updated);
            UserX.i.user(saved);
          };
          title = "Switch to business";
        } else if (user.authenticatedUserType ==
            AuthenticatedUserType.emailBusinessSide) {
          return SizedBox();
        } else {
          throw BappImpossibleException(
              "set the user's authenticatedUserType in strapi, might be null");
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
}
