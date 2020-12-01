import 'package:bapp/classes/firebase_structures/favorite.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/business_profile/business_profile.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/login_widget.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class FavoritesTab extends StatefulWidget {
  @override
  _FavoritesTabState createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CloudStore>(builder: (_, cloudStore, __) {
      return Observer(
        builder: (_) {
          final favBranches = cloudStore.favorites
              .where((element) => element.type == FavoriteType.businessBranch)
              .toList();
          return cloudStore.status == AuthStatus.anonymousUser
              ? AskToLoginWidget(
                  loginReason: LoginConfig.favoritesTabLoginReason.primary,
                  secondaryReason:
                      LoginConfig.favoritesTabLoginReason.secondary,
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
                                key: Key(favBranches[i]
                                    .businessBranch
                                    .myDoc
                                    .value
                                    .path),
                                child: BusinessTileWidget(
                                  titleStyle:
                                      Theme.of(context).textTheme.subtitle1,
                                  withImage: true,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 0),
                                  branch: favBranches[i].businessBranch,
                                  onTap: () async {
                                    flow.branch = favBranches[i].businessBranch;
                                    BappNavigator.bappPush(
                                      context,
                                      BusinessProfileScreen(),
                                    );
                                  },
                                ),
                                onDismissed: (d) {
                                  Provider.of<CloudStore>(context,
                                          listen: false)
                                      .addOrRemoveFavorite(favBranches[i]);
                                },
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

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);
}
