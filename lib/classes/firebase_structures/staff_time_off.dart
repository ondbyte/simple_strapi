/* import 'package:bapp/classes/firebase_structures/business_staff.dart';
import 'package:bapp/config/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum StaffTimeOffType { wholeDay, partial }

class StaffTimeOff {
  final DocumentReference myDoc;
  final BusinessStaff staff;
  final StaffTimeOffType type;
  DateTime from, to;
  String reason;

  StaffTimeOff(
      {this.type,
      this.myDoc,
      this.staff,
      this.from,
      this.to,
      this.reason = ""});

  static StaffTimeOff fromSnap(DocumentSnapshot snap, BusinessStaff staff) {
    final data = snap.data();
    return StaffTimeOff(
        type: EnumToString.fromString(StaffTimeOffType.values, data["type"]),
        myDoc: snap.reference,
        staff: staff,
        to: (data["to"] as Timestamp).toDate(),
        from: (data['from'] as Timestamp).toDate(),
        reason: data["reason"] ?? "");
  }

  static DocumentReference newRef() {
    return FirebaseFirestore.instance
        .collection("staff_time_off")
        .doc(kUUIDGen.v1());
  }

  toMap() {
    return {
      "myDoc": myDoc,
      "type": EnumToString.convertToString(type),
      "staff": staff.contactNumber.internationalNumber,
      "from": Timestamp.fromDate(from),
      "to": Timestamp.fromDate(to),
      "reason": reason ?? "",
    };
  }

  Future save() async {
    await myDoc.set(toMap());
  }

  Future delete() async {
    await myDoc.delete();
  }
}
 */