import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/business_profile/business_profile.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/widgets/login_widget.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class FavoritesTab extends StatefulWidget {
  @override
  _FavoritesTabState createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      return Obx(
        () {
          final favBranches = UserX.i.user()?.favourites ?? [];
          return UserX.i.userNotPresent
              ? AskToLoginWidget(
                  loginReason: LoginConfig.favoritesTabLoginReason.primary,
                  secondaryReason:
                      LoginConfig.favoritesTabLoginReason.secondary,
                )
              : favBranches.isEmpty
                  ? Center(
                      child: Text("No favorites"),
                    )
                  : CustomScrollView(
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              ListView.builder(
                                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                shrinkWrap: true,
                                itemCount: favBranches.length,
                                itemBuilder: (_, i) {
                                  return Dismissible(
                                    key: Key(
                                      favBranches[i].business?.id ?? "",
                                    ),
                                    onDismissed: (d) async {
                                      final user = UserX.i.user();
                                      user?.favourites?.remove(d);
                                      UserX.i.user(user);
                                      if (user is User) {
                                        final updated =
                                            await Users.update(user);
                                        if (updated is User) {
                                          UserX.i.user(updated);
                                        }
                                      }
                                    },
                                    child: Builder(builder: (_) {
                                      final business = favBranches[i].business;
                                      return (business is Business)
                                          ? BusinessTileWidget(
                                              titleStyle: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1 ??
                                                  TextStyle(),
                                              withImage: true,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 0,
                                              ),
                                              branch: business,
                                              onTap: () async {
                                                final business =
                                                    favBranches[i].business;
                                                if (business is Business) {
                                                  Get.to(
                                                    BusinessProfileScreen(
                                                      business: business,
                                                    ),
                                                  );
                                                }
                                              },
                                            )
                                          : SizedBox();
                                    }),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    );
        },
      );
    });
  }
}
