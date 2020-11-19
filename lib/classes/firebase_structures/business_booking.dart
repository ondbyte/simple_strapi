import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
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
}

enum BusinessBookingStatus {
  cancelledByUser,
  cancelledByStaff,
  cancelledByReceptionist,
  cancelledByManager,
  pending,
  ongoing,
  finished,
  noShow
}
