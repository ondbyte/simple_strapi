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
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class LocationSwitch extends StatefulWidget {
  LocationSwitch({Key? key}) : super(key: key);

  @override
  _LocationSwitchState createState() => _LocationSwitchState();
}

class _LocationSwitchState extends State<LocationSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final data = await Get.to(PickAPlaceScreen());
        if (data is City) {
          await DefaultDataX.i.setLocalityOrCity(city: data);
        } else {
          await DefaultDataX.i.setLocalityOrCity(locality: data);
        }
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
              return Obx(
                () {
                  final dd = DefaultDataX.i.defaultData();
                  final user = UserX.i.user();
                  return Text(
                    user == null
                        ? placeName(
                              city: dd?.city,
                              locality: dd?.locality,
                            ) ??
                            ""
                        : placeName(
                              city: user.city,
                              locality: user.locality,
                            ) ??
                            "",
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
