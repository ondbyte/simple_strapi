import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bapp/config/config.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:device_info/device_info.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart' hide Action;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:geocoder/geocoder.dart' as g;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart' show Action;
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';
import 'package:bapp/helpers/extensions.dart';

class Helper {
  static stringifyAddresse(g.Address adr) {
    return '''${adr.subLocality ?? ""}\n${adr.locality ?? ""}\n${adr.addressLine ?? ""}\n${adr.adminArea ?? ""}\n${adr.postalCode ?? ""}'''
        .split("\n")
        .join(", ");
  }

  static Future<bool> isTablet() async {
    if (Platform.isIOS) {
      final deviceInfo = DeviceInfoPlugin();
      var iosInfo = await deviceInfo.iosInfo;

      return iosInfo.model.toLowerCase() == "ipad";
    } else {
      final window = WidgetsBinding.instance?.window;
      if (window is SingletonFlutterWindow) {
        final data = MediaQueryData.fromWindow(window);
        return data.size.shortestSide < 600 ? false : true;
      }
    }
    return false;
  }

  static void bPrint(d) {
    print("[BAPP] ${d.toString()}");
  }

  static dynamic alternateLatLong(dynamic ll) {
    if (ll is Coordinates) {
      return LatLng(ll.latitude ?? 0, ll.longitude ?? 0);
    }
    if (ll is LatLng) {
      return Coordinates(
        latitude: ll.latitude,
        longitude: ll.longitude,
      );
    }
  }

  /*static List<List<MenuItem>>? filterMenuItems(
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
 */
}

T getStore<T>(BuildContext context) {
  return Provider.of<T>(context, listen: false);
}

bool isNotNullOrEmpty(dynamic variable) => !isNullOrEmpty(variable);

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

/* 
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
        Helper.bPrint("Unable to delete file on storage");
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
        final bytes = Uint8List.fromList(encodePng(thumbedData));
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
 */
String removeLocalFromPath(String path) {
  return path.replaceFirst("local", "");
}

String nameFromPath(String path, {String extension = ""}) {
  return path.split("/").last + "";
}
/* 
Future uploadBusinessBranchApprovalPDF({File? fileToUpload}) async {
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
} */

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
    unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
    indicatorColor: Theme.of(context).primaryColor,
    indicatorPadding: const EdgeInsets.all(16),
    indicatorWeight: 6,
    indicatorSize: TabBarIndicatorSize.tab,
    labelPadding: const EdgeInsets.only(bottom: 16, top: 8),
    tabs: tabs,
  );
}

Future sendUpdatesForBooking(Booking booking) async {
  final status = booking.bookingStatus;

  switch (status) {
    case BookingStatus.pendingApproval:
      {}
  }
}

String readableEnum(dynamic value) {
  return EnumToString.convertToString(value).split(r"(?=[A-Z])").join(" ");
}

void documentIntegrityError(e, s, data) {
  Helper.bPrint(kDocumenIntegrityError);
  Helper.bPrint("Document data/snap is");
  Helper.bPrint("$data");
  Helper.bPrint("Error and StackTrace");
  Helper.bPrint("$e");
  Helper.bPrint("$s");
}

void bPrint(d) {
  print("[BAPP] ${d.toString()}");
}

bool get isMobile => (Platform.isAndroid || Platform.isIOS);

bool get isWeb => kIsWeb;

class BappImpossibleException implements Exception {
  final String message;

  BappImpossibleException(this.message);
}

class DateFormatters {
  static final dayName = DateFormat.EEEE();
}

String getNProductsSelectedString(List<Product> products) {
  return "${products.length} products selected";
}

String getProductsDurationString(List<Product> products) {
  final duration =
      products.fold<int>(0, (pv, product) => pv + (product.duration ?? 0));
  return "total duration of $duration minutes";
}

List<Timing> divideTimingIntoChunksOfDuration(Timing timing,
    {Duration duration = const Duration(minutes: 5)}) {
  final returnable = <Timing>[];
  var start = timing.from, end = timing.from?.add(duration), max = timing.to;
  while (max is DateTime &&
      start is DateTime &&
      end is DateTime &&
      end.isBefore(max)) {
    returnable.add(
      Timing(from: start, to: end),
    );
  }
  return returnable;
}

Map<String, List<Timing>> sortTimingsForPeriodOfTheDay(List<Timing> timings) {
  final morning = <Timing>[];
  final afterNoon = <Timing>[];
  final evening = <Timing>[];

  final compare = (DateTime date) {
    final now = date.toTimeOfDay();
    if (now.isAM()) {
      return 0;
    }
    if (now.hour < 3 && now.minute <= 59) {
      return 1;
    }
    return 2;
  };
  timings.forEach((timing) {
    final compared = compare(timing.from!);
    if (compared == 1) {
      morning.add(timing);
    } else if (compared == 2) {
      afterNoon.add(timing);
    } else {
      evening.add(timing);
    }
  });
  return {
    "morning": morning,
    "afterNoon": afterNoon,
    "evening": evening,
  };
}
