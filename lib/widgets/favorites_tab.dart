import 'package:bapp/config/config.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_widget.dart';
import 'store_provider.dart';

class FavoritesTab extends StatefulWidget {
  @override
  _FavoritesTabState createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AuthStore>(
      store: Provider.of<AuthStore>(context, listen: false),
      builder: (_, authStore) {
        return authStore.status == AuthStatus.anonymousUser
            ? LoginWidget(
                loginReason: LoginConfig.bookingTabLoginReason.primary,
                secondaryReason: LoginConfig.bookingTabLoginReason.secondary,
              )
            : CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(),
                    ]),
                  )
                ],
              );
      },
    );
  }
}
