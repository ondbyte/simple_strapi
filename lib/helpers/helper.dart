import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bapp/config/config.dart';
import 'package:bapp/config/constants.dart';
import 'package:device_info/device_info.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart' hide Action;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:geocoder/geocoder.dart' as g;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' hide Color;
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart' show Action;
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:recase/recase.dart';

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
    // indicatorPadding: const EdgeInsets.all(16),
    indicatorWeight: 6,
    indicatorSize: TabBarIndicatorSize.tab,
    labelPadding: const EdgeInsets.only(bottom: 8, top: 8),
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
  @override
  String toString() {
    return message;
  }
}

bool isCancellableBooking(Booking booking) {
  switch (booking.bookingStatus) {
    case BookingStatus.cancelledByUser:
    case BookingStatus.cancelledByStaff:
    case BookingStatus.cancelledByReceptionist:
    case BookingStatus.cancelledByManager:
    case BookingStatus.cancelledByOwner:
    case BookingStatus.walkin:
    case BookingStatus.ongoing:
    case BookingStatus.finished:
    case BookingStatus.noShow:
    case BookingStatus.halfWayThrough:
      return false;
    case BookingStatus.pendingApproval:
    case BookingStatus.accepted:
      return true;
    default:
      return false;
  }
}

List<Booking> getBookingsForDay(List<Booking> bookings, DateTime day) {
  return bookings
      .where((element) => element.bookingStartTime?.isDay(day) ?? false)
      .toList();
}

String getNProductsSelectedString(List<Product> products) {
  return "${products.length} products selected";
}

String getProductsDurationString(List<Product> products) {
  final duration =
      products.fold<int>(0, (pv, product) => pv + (product.duration ?? 0));
  return "total duration of $duration minutes";
}

String getProductsCostString(List<Product> products) {
  final duration =
      products.fold<double>(0, (pv, product) => pv + (product.price ?? 0.0));
  return "total of $duration AED";
}

String getOnForTime(DateTime date) {
  return "On ${DateFormat("MMM d, h:mm a").format(date.toLocal())}";
}

List<Timing> divideTimingIntoChunksOfDuration(Timing timing,
    {Duration duration = const Duration(minutes: 15)}) {
  final returnable = <Timing>[];
  var _startX = duration.inMinutes -
      (timing.from?.minute ?? 0).remainder(duration.inMinutes) -
      15;
  var frm = timing.from!;
  var start = DateTime(
          frm.year, frm.month, frm.day, frm.hour, frm.minute + _startX),
      end = timing.from?.add(duration),
      max = timing.to;
  while (max is DateTime &&
      start is DateTime &&
      end is DateTime &&
      (end.isBefore(max) || end.isAtSameMomentAs(max))) {
    returnable.add(
      Timing(from: start, to: end),
    );
    start = end;
    end = start.add(duration);
  }
  return returnable;
}

Map<String, List<Timing>> sortTimingsForPeriodOfTheDay(List<Timing> timings) {
  final morning = <Timing>[];
  final afterNoon = <Timing>[];
  final evening = <Timing>[];

  final compare = (DateTime date) {
    final now = date.toTimeOfDay();
    if (now.hour <= 11 && now.minute <= 59) {
      return 0;
    }
    if (now.hour <= 14 && now.minute <= 59) {
      return 1;
    }
    return 2;
  };
  timings.forEach((timing) {
    final compared = compare(timing.from!);
    if (compared == 0) {
      morning.add(timing);
    } else if (compared == 1) {
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

T? getOfIdFromList<T>(String id, List<dynamic> list) {
  bPrint("getOfIdFromList ${list.runtimeType}");
  bPrint("id: $id");
  bPrint(list);
  return list.firstWhere((element) => element.id == id, orElse: () => null);
}

MapEntry<DateTime, DateTime> startAndEndOfTheDayOf(DateTime day) {
  return MapEntry(
    DateTime(day.year, day.month, day.day, 0, 0, 0),
    DateTime(day.year, day.month, day.day, 23, 59, 0),
  );
}

Map<DateTime, List> bookingsAsCalendarEvents(List<Booking> bookings) {
  return Map.fromEntries(bookings
      .map((e) => MapEntry(e.bookingStartTime!, [e.bookedByUser?.name ?? ""])));
}

Map<DateTime, List> holidaysAsCalendarEvents(List<Holiday> holidays) {
  return Map.fromEntries(
      holidays.map((e) => MapEntry(e.date!, [e.nameOfTheHoliday ?? ""])));
}

String getAboutTabTimingString(List<Timing> timings) {
  var returnable = "";
  timings.forEach((e) {
    final from = e.from;
    final to = e.to;
    if (from is DateTime && to is DateTime) {
      returnable = returnable +
          "${DateFormatters.aboutTab.format(from)} to ${DateFormatters.aboutTab.format(to)},";
    }
  });
  return returnable;
}

class DateFormatters {
  static final dayName = DateFormat.EEEE();
  static final at = DateFormat.EEEE();
  static final aboutTab = DateFormat("h:mm a");
}

Color getColorForBooking(BookingStatus? status) {
  switch (status) {
    case BookingStatus.accepted:
    case BookingStatus.ongoing:
      {
        return CardsColor.colors["teal"] ?? Colors.teal;
      }
    case BookingStatus.walkin:
    case BookingStatus.pendingApproval:
      {
        return CardsColor.colors["purple"] ?? Colors.purple;
      }
    case BookingStatus.cancelledByUser:
      {
        return CardsColor.colors["orange"] ?? Colors.orange;
      }
    case BookingStatus.cancelledByManager:
    case BookingStatus.cancelledByReceptionist:
    case BookingStatus.cancelledByStaff:
    case BookingStatus.noShow:
      {
        return Colors.redAccent;
      }
    case BookingStatus.finished:
      {
        return Colors.grey.shade400;
      }
    default:
      return Colors.grey.shade300;
  }
}

String readableEnum(enumerator) {
  final s = EnumToString.convertToString(enumerator);
  return ReCase("$s").sentenceCase;
}

bool isValidEmail(String? s) {
  if (s is! String) {
    return false;
  }
  return RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(s);
}
