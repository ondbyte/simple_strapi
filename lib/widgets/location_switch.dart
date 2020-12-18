import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/location/pick_a_place.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class LocationSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        BappNavigator.push(context, PickAPlaceScreen());
      },
      child: Row(
        children: [
          Icon(
            FeatherIcons.mapPin,
            color: Theme.of(context).iconTheme.color,
            size: 16,
          ),
          SizedBox(
            width: 10,
          ),
          Consumer<CloudStore>(
            builder: (_, cloudStore,__) {
              return Observer(
                builder: (_) {
                  final bappUser = cloudStore.bappUser;
                  return Text(
                    isNullOrEmpty(bappUser.address.locality)?
                        bappUser.address.city:bappUser.address.locality,
                    style: Theme.of(context).textTheme.subtitle1,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
