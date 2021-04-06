/* import 'package:bapp/classes/firebase_structures/rating.dart';
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
  final DateTime? remindTime;
  final String bookedByName;
  final CompleteBookingRating rating;
  final String staffNumber;
  final String managerNumber;
  final String receptionistNumber;
  final String ownerNumber;
  final cancelReason = Observable("");

  final DocumentReference myDoc;

  BusinessBooking({
    required this.myDoc,
    required this.bookingUserType,
    required BusinessBookingStatus status,
    required this.bookedByNumber,
    required this.staff,
    required this.branch,
    required this.fromToTiming,
    required this.services,
    required this.remindTime,
    required this.bookedByName,
    required this.rating,
    required this.staffNumber,
    required this.managerNumber,
    required this.receptionistNumber,
    required this.ownerNumber,
    String cancelReason = "",
  }) {
    this.status.value = status;
    this.cancelReason.value = cancelReason;
  }

  static DocumentReference newDoc() {
    return FirebaseFirestore.instance.collection("bookings").doc(kUUIDGen.v1());
  }

  Future<bool> save() async {
    await myDoc.set(toMap());
    return true;
  }

  Future saveRating() async {
    final tmp = rating.toMap();
    await myDoc.update({"rating": tmp});
  }

  Future<bool> cancel(
      {required BusinessBookingStatus withStatus, String reason = ""}) {
    var done = Future.value(false);
    act(() {
      status.value = withStatus;
      cancelReason.value = reason;
      done = save();
    });
    return done;
  }

  Future<bool> startJob() async {
    act(() {
      status.value = BusinessBookingStatus.ongoing;
    });
    return save();
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
      "remindTime": remindTime?.toTimeStamp(),
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
      "cancelReason": cancelReason.value
    };
  }

  static BusinessBooking fromSnapShot(
      {required DocumentSnapshot snap, required BusinessBranch branch}) {
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
      remindTime: (j?["remindTime"] as Timestamp)?.toDate(),
      bookedByName: j["bookedByName"] ?? "",
      rating: CompleteBookingRating.fromJson(j["rating"] ?? {}),
      staffNumber: j["staffNumber"] ?? "",
      receptionistNumber: j["receptionistNumber"] ?? "",
      managerNumber: j["managerNumber"] ?? "",
      ownerNumber: j["ownerNumber"] ?? "",
      cancelReason: j["cancelReason"] ?? "",
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

  static Color getColor(BookingStatus? status) {
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

  static String getButtonLabel(BookingStatus? status) {
    switch (status) {
      case BookingStatus.accepted:
        {
          return "Confirmed";
        }
      case BookingStatus.ongoing:
        {
          return "Ongoing";
        }
      case BookingStatus.walkin:
        {
          return "Walk-in";
        }
      case BookingStatus.pendingApproval:
        {
          return "Pending";
        }
      case BookingStatus.cancelledByUser:
        {
          return "Cancelled";
        }
      case BookingStatus.cancelledByManager:
      case BookingStatus.cancelledByReceptionist:
      case BookingStatus.cancelledByStaff:
        {
          return "Rejected";
        }
      case BookingStatus.noShow:
        {
          return "No show";
        }
      case BookingStatus.finished:
        {
          return "Completed";
        }
      default:
        return "Unknown";
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is BusinessBooking) {
      return myDoc == other.myDoc;
    }
    return false;
  }
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
 */