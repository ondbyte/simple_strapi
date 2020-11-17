import 'package:bapp/helpers/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

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

  DocumentReference myDoc;

  BusinessBooking(
      {this.status,
      this.bookedByNumber,
      this.staff,
      this.branch,
      this.fromToTiming,
      this.services});

  toMap() {
    return {
      "staff": staff.name,
      "from": fromToTiming.from.toTimeStamp(),
      "to": fromToTiming.to.toTimeStamp(),
      "services": services.map((e) => e.toMap()).toList(),
      "branch": branch.myDoc,
      "user": bookedByNumber,
      "status": EnumToString.convertToString(status),
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
