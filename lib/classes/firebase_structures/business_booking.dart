import 'package:bapp/config/config.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  final BusinessBookingStatus status;
  final UserType bookingUserType;

  DocumentReference myDoc;

  BusinessBooking({
    @required this.bookingUserType,
    @required this.status,
    @required this.bookedByNumber,
    @required this.staff,
    @required this.branch,
    @required this.fromToTiming,
    @required this.services,
  });

  Map<String, dynamic> toMap() {
    return {
      "staff": staff.name,
      "from": fromToTiming.from.toTimeStamp(),
      "to": fromToTiming.to.toTimeStamp(),
      "services": services.map((e) => e.toMap()).toList(),
      "branch": branch.myDoc.value,
      "bookedByNumber": bookedByNumber,
      "status": EnumToString.convertToString(status),
      "bookingUserType": EnumToString.convertToString(bookingUserType),
    };
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

  static Color getColor(BusinessBookingStatus status) {
    switch (status) {
      case BusinessBookingStatus.accepted:
      case BusinessBookingStatus.ongoing:
        {
          return CardsColor.colors["teal"];
        }
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
    }
  }

  static String getButtonLabel(BusinessBookingStatus status) {
    switch (status) {
      case BusinessBookingStatus.accepted:
      case BusinessBookingStatus.ongoing:
        {
          return "Confirmed";
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
    }
  }
}

enum BusinessBookingStatus {
  cancelledByUser,
  cancelledByStaff,
  cancelledByReceptionist,
  cancelledByManager,
  walkin,
  pending,
  accepted,
  ongoing,
  finished,
  noShow
}
