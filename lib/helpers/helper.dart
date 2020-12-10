import 'dart:io';

import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/fcm.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart' hide Action;
import 'package:flutter/material.dart' hide Action;
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart';
import 'package:mobx/mobx.dart' show Action;
import 'package:provider/provider.dart';

class Helper {
  static stringifyAddresse(Address adr) {
    return '''${adr.subLocality ?? ""}\n${adr.locality ?? ""}\n${adr.addressLine ?? ""}\n${adr.adminArea ?? ""}\n${adr.postalCode ?? ""}'''
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
    print("[BAPP]" + d.toString());
  }

  static dynamic alternateLatLong(dynamic ll) {
    if (ll is GeoPoint) {
      return LatLng(ll.latitude, ll.longitude);
    }
    if (ll is LatLng) {
      return GeoPoint(ll.latitude, ll.longitude);
    }
  }

  static List<List<MenuItem>> filterMenuItems(
      UserType userType, UserType alterEgo, AuthStatus authStatus) {
    final ls = <List<MenuItem>>[];
    MenuConfig.menuItems.forEach(
      (element) {
        final l = <MenuItem>[];
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
    return ls;
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
  if (variable is Map) {
    return variable.isEmpty;
  }
  if (variable is Iterable) {
    return variable.isEmpty;
  }
  if (variable is String) {
    return variable.isEmpty;
  }
  return false;
}

dynamic act(Function fn) async {
  return Action(() async {
    return await fn();
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

Future<Map<String, bool>> uploadImagesToStorageAndReturnStringList(
    Map<String, bool> imagesWithFiltered,
    {String path = ""}) async {
  if (imagesWithFiltered == null || imagesWithFiltered.isEmpty) {
    return {};
  }
  final f = FirebaseStorage.instance;
  final a = FirebaseAuth.instance;
  final storagePaths = <String, bool>{};

  final folder = path.isEmpty
      ? f.ref().child(a.currentUser.uid)
      : f.ref().child(a.currentUser.uid).child(path);

  await Future.forEach<MapEntry<String, bool>>(imagesWithFiltered.entries,
      (entry) async {
    if (!entry.value) {
      try {
        await f.ref().child(entry.key).delete();
      } catch (e, s) {
        Helper.printLog("Unable to delete file on storage");
        print(e);
        print(s);
      }
    } else {
      if (entry.key.startsWith("local")) {
        final uints = await File(removeLocalFromPath(entry.key)).readAsBytes();
        var thumbedData = decodeImage(uints);
        if (thumbedData.width > 849) {
          thumbedData = copyResize(thumbedData, width: 800);
        }
        final bytes = encodePng(thumbedData);
        final task = folder
            .child(nameFromPath(entry.key, extension: ".png"))
            .putData(bytes);
        final done = await task;
        storagePaths.addAll({done.ref.fullPath: true});
      } else {
        storagePaths.addAll({entry.key: entry.value});
      }
    }
  });
  return storagePaths;
}

String removeLocalFromPath(String path) {
  return path.replaceFirst("local", "");
}

String nameFromPath(String path, {String extension = ""}) {
  return path.split("/").last + "";
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
  await task;
  print("File Uploaded");
}

PreferredSizeWidget getBappTabBar(BuildContext context, List<Widget> tabs) {
  return TabBar(
    indicator: UnderlineTabIndicator(
      insets: EdgeInsets.zero,
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 2,
      ),
    ),
    labelColor: Theme.of(context).primaryColor,
    unselectedLabelColor: Theme.of(context).indicatorColor,
    indicatorColor: Theme.of(context).primaryColor,
    indicatorPadding: const EdgeInsets.all(16),
    indicatorWeight: 6,
    indicatorSize: TabBarIndicatorSize.tab,
    labelPadding: const EdgeInsets.all(8),
    tabs: tabs,
  );
}

Future sendUpdatesForBooking(BusinessBooking booking) async {
  final status = booking.status.value;

  switch (status) {
    case BusinessBookingStatus.pending:
      {
        final message = BappFCMMessage(
          type: MessagOrUpdateType.bookingUpdate,
          title: "There's a new booking",
          body:
              "at ${booking.fromToTiming.from}, includes ${booking.getServicesSeperatedBycomma()}",
          to: "",
        );
      }
  }
}

String readableEnum(dynamic value) {
  return EnumToString.convertToString(value).split(r"(?=[A-Z])").join(" ");
}
