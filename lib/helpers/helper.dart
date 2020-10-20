import 'dart:io';
import 'dart:typed_data';

import 'package:bapp/config/config.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart' hide Action;
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart' show Action;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';

class Helper {
  static stringifyAddresse(Address adr) {
    return '''${adr.subLocality}\n${adr.locality}\n${adr.addressLine}\n${adr.adminArea}\n${adr.postalCode}'''
        .split("\n")
        .join(", ");
  }

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

  static dynamic alternateLatLong(dynamic ll) {
    if (ll is GeoPoint) {
      return LatLng(ll.latitude, ll.longitude);
    }
    if (ll is LatLng) {
      return GeoPoint(ll.latitude, ll.longitude);
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

T getStore<T>(BuildContext context) {
  return Provider.of<T>(context, listen: false);
}

bool isNullOrEmpty(dynamic variable) {
  if (variable == null) {
    return true;
  }
  if (variable is Iterable) {
    return variable.isEmpty;
  }
  if (variable is String) {
    return variable.isEmpty;
  }
  return false;
}

dynamic act(Function fn) {
  return Action(() {
    return fn();
  }).call();
}

String localOrNetworkFilePath(String path) {
  if (path.startsWith("http")) {
    return path;
  }
  return "file:///" + path;
}

String removeNewLines(String s) {
  return s.split("\n").join(", ");
}

Future<List<String>> uploadImagesToStorageAndReturnStringList(
    Map<String, bool> imagesWithFiltered,
    {String path = ""}) async {
  final f = FirebaseStorage.instance;
  final a = FirebaseAuth.instance;
  final List<String> storagePaths = [];

  final folder = path.isEmpty
      ? f.ref().child(a.currentUser.uid)
      : f.ref().child(a.currentUser.uid).child(path);

  await Future.forEach<MapEntry<String, bool>>(imagesWithFiltered.entries,
      (entry) async {
    if (!entry.value) {
      await f.ref().child(entry.key).delete();
    } else {
      if (entry.key.startsWith("local")) {
        final file = File(removeLocalFromPath(entry.key));
        final task = folder.child(nameFromPath(entry.key)).putFile(file);
        final done = await task.onComplete;
        storagePaths.add(done.ref.path);
      } else {
        storagePaths.add(entry.key);
      }
    }
  });
  return storagePaths;
}

String removeLocalFromPath(String path) {
  return path.replaceFirst("local", "");
}

String nameFromPath(String path) {
  return path.split("/").last;
}

Future uploadBusinessBranchApprovalPDF({File fileToUpload}) async {
  final f = FirebaseStorage.instance;
  final a = FirebaseAuth.instance;

  final file = f
      .ref()
      .child(a.currentUser.uid)
      .child("submittedPdf")
      .child(DateTime.now().toIso8601String() + ".pdf");

  final task = file.putFile(fileToUpload);
  await task.onComplete;
  print("File Uploaded");
}
