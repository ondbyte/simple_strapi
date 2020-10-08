import 'dart:io';

import 'package:bapp/config/config.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/constants.dart';

class Helper {
  static Future<bool> isTablet() async {
    if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      return iosInfo.model.toLowerCase() == "ipad";
    } else {
      final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
      return data.size.shortestSide < 600 ? false : true;
    }
  }

  static void printLog(d) {
    print("[BAPP]" + d);
  }

  static dynamic alternateLatLong(dynamic ll){
    if(ll is GeoPoint){
      return LatLng(ll.latitude, ll.longitude);
    }
    if(ll is LatLng){
      return GeoPoint(ll.latitude,ll.longitude);
    }
  }

  static filterMenuItems(
      UserType userType, UserType alterEgo, AuthStatus authStatus) {
    final List<List<MenuItem>> ls = [];
    MenuConfig.menuItems.forEach(
      (element) {
        final List<MenuItem> l = [];
        element.forEach((el) {
          if (el.showWhenUserTypeIs.contains(userType)) {
            if (el.showWhenAlterEgoIs.contains(alterEgo)) {
              if (el.showWhenAuthStatusIs.contains(authStatus)) {
                l.add(el);
              }
            }
          }
        });
        ls.add(l);
      },
    );
    kFilteredMenuItems = ls;
    //print(ls);
  }
}
