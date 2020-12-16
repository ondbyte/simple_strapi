import 'package:bapp/classes/firebase_structures/rating.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';

import 'business_branch.dart';
import 'business_services.dart';
import 'business_staff.dart';
import 'business_timings.dart';

class BusinessBooking {
  final BusinessStaff staff;
  final BusinessBranch branch;
  final FromToTiming fromToTiming;
  final List<BusinessService> services;
  final String bookedByNumber;
  final status = Observable<BusinessBookingStatus>(null);
  final UserType bookingUserType;
  final DateTime remindTime;
  final String bookedByName;
  final CompleteBookingRating rating;
  final String staffNumber;
  final String managerNumber;
  final String receptionistNumber;
  final String ownerNumber;

  final DocumentReference myDoc;

  BusinessBooking({
    @required this.myDoc,
    @required this.bookingUserType,
    @required BusinessBookingStatus status,
    @required this.bookedByNumber,
    @required this.staff,
    @required this.branch,
    @required this.fromToTiming,
    @required this.services,
    @required this.remindTime,
    @required this.bookedByName,
    @required this.rating,
    @required this.staffNumber,
    @required this.managerNumber,
    @required this.receptionistNumber,
    @required this.ownerNumber,
  }) {
    this.status.value = status;
  }

  static DocumentReference newDoc() {
    return FirebaseFirestore.instance.collection("bookings").doc(kUUIDGen.v1());
  }

  Future<bool> save() async {
    await myDoc.set(toMap());
  }

  Future saveRating() async {
    final tmp = rating.toMap();
    tmp["isRated"] = true;
    await myDoc.update({"rating": tmp});
  }

  Future<bool> cancel({@required BusinessBookingStatus withStatus}) {
    var done = Future.value(false);
    act(() {
      status.value = withStatus;
      done = save();
    });
    return done;
  }

  Future<bool> accept() async {
    var done = Future.value(false);
    act(() {
      status.value = BusinessBookingStatus.accepted;
      done = save();
    });
    return done;
  }

  Map<String, dynamic> toMap() {
    return {
      "staff": staff.name,
      "from": fromToTiming.from.toTimeStamp(),
      "to": fromToTiming.to.toTimeStamp(),
      "remindTime": remindTime.toTimeStamp(),
      "services": services.map((e) => e.toMap()).toList(),
      "branch": branch.myDoc.value,
      "bookedByNumber": bookedByNumber,
      "status": EnumToString.convertToString(status.value),
      "bookingUserType": EnumToString.convertToString(bookingUserType),
      "bookedByName": bookedByName,
      "rating": rating.toMap(),
      "staffNumber": staffNumber,
      "receptionistNumber": receptionistNumber,
      "managerNumber": managerNumber,
      "ownerNumber": ownerNumber,
    };
  }

  static BusinessBooking fromSnapShot(
      {@required DocumentSnapshot snap, @required BusinessBranch branch}) {
    final j = snap.data();
    return BusinessBooking(
      myDoc: snap.reference,
      services: (j["services"] as List).map(
        (s) {
          return BusinessService.fromJson(s);
        },
      ).toList(),
      staff: branch.getStaffFor(name: j["staff"]),
      branch: branch,
      fromToTiming: FromToTiming.fromTimeStamps(
        from: j["from"],
        to: j["to"],
      ),
      status:
          EnumToString.fromString(BusinessBookingStatus.values, j["status"]),
      bookedByNumber: j["bookedByNumber"],
      bookingUserType: EnumToString.fromString(
        UserType.values,
        j["bookingUserType"],
      ),
      remindTime: (j["remindTime"] as Timestamp)?.toDate(),
      bookedByName: j["bookedByName"] ?? "",
      rating: CompleteBookingRating.fromJson(j["rating"] ?? {}),
      staffNumber: j["staffNumber"] ?? "",
      receptionistNumber: j["receptionistNumber"] ?? "",
      managerNumber: j["managerNumber"] ?? "",
      ownerNumber: j["ownerNumber"] ?? "",
    );
  }

  double totalCost() {
    var t = 0.0;
    services.forEach((element) {
      t += element.price.value;
    });
    return t;
  }

  String getServicesSeperatedBycomma() {
    var s = "";
    services.forEach((element) {
      s += element.serviceName.value + ", ";
    });
    //s = s.trim().replaceFirst(",", "", s.length - 1);
    return s;
  }

  Map<String, String> getServiceNamesWithDuration() {
    final map = <String, String>{};
    services.forEach((element) {
      map.addAll({
        element.serviceName.value:
            element.duration.value.inMinutes.toString() + ", " + "Minutes"
      });
    });
    return map;
  }

  bool isActive() {
    if (status == null) {
      return false;
    }
    return status.value == BusinessBookingStatus.pending ||
        status.value == BusinessBookingStatus.accepted;
  }

  Future sendBookingUpdate() async {}

  static Color getColor(BusinessBookingStatus status) {
    switch (status) {
      case BusinessBookingStatus.accepted:
      case BusinessBookingStatus.ongoing:
        {
          return CardsColor.colors["teal"];
        }
      case BusinessBookingStatus.walkin:
      case BusinessBookingStatus.pending:
        {
          return CardsColor.colors["purple"];
        }
      case BusinessBookingStatus.cancelledByUser:
        {
          return CardsColor.colors["orange"];
        }
      case BusinessBookingStatus.cancelledByManager:
      case BusinessBookingStatus.cancelledByReceptionist:
      case BusinessBookingStatus.cancelledByStaff:
      case BusinessBookingStatus.noShow:
        {
          return Colors.redAccent;
        }
      case BusinessBookingStatus.finished:
        {
          return Colors.grey[400];
        }
      default:
        return Colors.grey[300];
    }
  }

  static String getButtonLabel(BusinessBookingStatus status) {
    switch (status) {
      case BusinessBookingStatus.accepted:
      case BusinessBookingStatus.ongoing:
        {
          return "Confirmed";
        }
      case BusinessBookingStatus.walkin:
        {
          return "Walkin";
        }
      case BusinessBookingStatus.pending:
        {
          return "New";
        }
      case BusinessBookingStatus.cancelledByUser:
        {
          return "Cancelled";
        }
      case BusinessBookingStatus.cancelledByManager:
      case BusinessBookingStatus.cancelledByReceptionist:
      case BusinessBookingStatus.cancelledByStaff:
      case BusinessBookingStatus.noShow:
        {
          return "Rejected";
        }
      case BusinessBookingStatus.finished:
        {
          return "Completed";
        }
      default:
        return "Unknown";
    }
  }

  static Future sendUpdatesForBooking(BusinessBooking booking) async {}
}

enum BusinessBookingStatus {
  cancelledByUser,
  cancelledByStaff,
  cancelledByReceptionist,
  cancelledByManager,
  cancelledByOwner,
  walkin,
  pending,
  accepted,
  ongoing,
  finished,
  noShow
}
