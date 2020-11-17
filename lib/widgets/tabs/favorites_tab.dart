import 'package:bapp/config/config.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../login_widget.dart';

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
                          SizedBox(),
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
