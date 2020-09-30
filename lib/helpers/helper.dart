import 'dart:io';

import 'package:bapp/config/config.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';

import 'constants.dart';

class Helper{
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

  static void printLog(d){
    print("[BAPP]"+ d);
  }

  static filterMenuItems(UserType userType,UserType alterEgo){
    final List<List<MenuItem>> ls = [];
    MenuConfig.menuItems.forEach((element) {
      final List<MenuItem> l = [];
      element.forEach((el) {
        if(el.showWhen.contains(userType)){
          if(el.specificToAlterEgo.contains(alterEgo)){
            l.add(el);
          }
        }
      });
      ls.add(l);
    });
    kFilteredMenuItems = ls;
    print(ls);
  }
}