import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/location/pick_a_place.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
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
          Builder(
            builder: (_) {
              return Observer(
                builder: (_) {
                  final bappUser = UserX.i.user();
                  return Text(
                    UserX.i.userNotPresent
                        ? placeName(
                              city: DefaultDataX.i.defaultData()?.city,
                              locality: DefaultDataX.i.defaultData()?.locality,
                            ) ??
                            "no place,inform yadu"
                        : placeName(
                              city: UserX.i.user()?.city,
                              locality: UserX.i.user()?.locality,
                            ) ??
                            "no place,inform yadu",
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
