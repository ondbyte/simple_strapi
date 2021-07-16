import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/location/pick_a_place.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/localityX.dart';
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
        if (data != null) {
          setLocation(data);
        } else {
          bPrint("No location is picked");
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

Future setLocation(cityOrLocality) async {
  if (UserX.i.user() == null) {
    if (cityOrLocality is City) {
      await DefaultDataX.i.setLocalityOrCity(city: cityOrLocality);
    } else {
      await DefaultDataX.i.setLocalityOrCity(locality: cityOrLocality);
    }
  } else {
    if (cityOrLocality is Locality) {
      await UserX.i.setLocalityOrCity(locality: cityOrLocality);
    } else {
      await UserX.i.setLocalityOrCity(city: cityOrLocality);
    }
  }
}

dynamic getLocation() {
  if (UserX.i.user() == null) {
    final city = DefaultDataX.i.defaultData()?.city;
    final locality = DefaultDataX.i.defaultData()?.locality;
    return city ?? locality;
  } else {
    final city = UserX.i.user()?.city;
    final locality = UserX.i.user()?.locality;
    return city ?? locality;
  }
}
