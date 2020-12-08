import 'dart:async';

import 'package:bapp/classes/firebase_structures/bapp_user.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/exceptions.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:thephonenumber/thecountrynumber.dart';

import 'business_branch.dart';

class BusinessStaff {
  UserType role;
  String name;
  DateTime dateOfJoining;
  Map<String, bool> images = {};
  final expertise = ObservableList<String>();

  BusinessBranch branch;
  BusinessStaff manager;
  BusinessStaff receptionist;
  TheNumber contactNumber;
  double rating = 0;

  DocumentSnapshot _userSnap;

  BusinessStaff({
    this.role,
    this.branch,
    this.contactNumber,
    this.name,
    this.dateOfJoining,
    this.images = const {},
    List<String> expertise,
    this.rating = 0,
  }) {
    if (expertise != null) {
      this.expertise.addAll(expertise);
    }
  }

  toMap() {
    return {
      "role": EnumToString.convertToString(role),
      "name": name,
      "dateOfJoining": dateOfJoining,
      "expertise": expertise.toList(),
      "branch": branch.myDoc.value,
      "contactNumber": contactNumber.internationalNumber,
      "images": images.keys.toList(),
      "rating": rating
    };
  }

  Future<DocumentSnapshot> _getUserSnap() async {
    final completer = Completer<DocumentSnapshot>();
    final collec = FirebaseFirestore.instance.collection("users");
    collec
        .where("contactNumber",
            isEqualTo: "${contactNumber.internationalNumber}")
        .snapshots()
        .listen(
      (snaps) async {
        if (snaps.docs.isEmpty) {
          ///the user with that number doesnt exist on bapp, lets create a temporary document with these details
          final userDoc =
              BappUser.newReference(docName: contactNumber.internationalNumber);
          final user = BappUser(
              myDoc: userDoc,
              image: images?.keys?.first ?? "",
              email: "",
              theNumber: contactNumber,
              name: name,
              branches: {branch.myDoc.value.id: branch.myDoc.value},
              business: branch.business.value.myDoc.value,
              alterEgo: role,
              userType: UserType.customer);
          await user.save();
        } else if (snaps.docs.length > 1) {
          throw BappException(
            msg: "This should never be the case",
            whatHappened: ""
                "when we search for a staff with their phone number in users collection it shouldn't return more than one doc",
          );
        } else {
          _userSnap = snaps.docs.first;
          completer.cautiousComplete(_userSnap);
        }
      },
    );
    return completer.future;
  }

  Future save() async {
    await branch.myDoc.value.set({
      "staff": {name: toMap()}
    }, SetOptions(merge: true));
  }

  Future delete() async {
    branch.staff.remove(this);
    await branch.myDoc.value.update({"staff.$name": FieldValue.delete()});
    await FirebaseFirestore.instance
        .collection("users")
        .doc(contactNumber.internationalNumber)
        .delete();
  }

  Future updateForUser() async {
    final snap = _userSnap ?? (await _getUserSnap());
    if (snap.exists) {
      await snap.reference.set({
        "branches": {branch.myDoc.value.id:branch.myDoc.value},
        "business": branch.business.value.myDoc.value
      }, SetOptions(merge: true));
    } else {
      print("user dont exist, this shouldn't be the case");
    }
  }

  Future deleteForUser() async {
    final snap = _userSnap ?? (await _getUserSnap());
    if (snap.exists) {
      await snap.reference
          .update({"branches.${branch.myDoc.value.id}": FieldValue.delete()});
    } else {
      print("user dont exist, this shouldn't be the case");
    }
  }

  void _fromJson(Map<String, dynamic> j) {
    role = EnumToString.fromString(UserType.values, j["role"]);
    name = j["name"];
    dateOfJoining = (j["dateOfJoining"] as Timestamp).toDate();
    expertise.addAll((j["expertise"] as List).map((e) => e as String).toList());
    contactNumber =
        TheCountryNumber().parseNumber(internationalNumber: j["contactNumber"]);
    images = {for (var v in j["images"]) v as String: true} ?? {};
    rating = j["rating"] ?? 0;
  }

  BusinessStaff.fromJson({@required this.branch, Map<String, dynamic> j}) {
    _fromJson(j);
  }

  @override
  bool operator ==(Object other) {
    if (other is BusinessStaff) {
      return name == other.name &&
          branch.myDoc.value == other.branch.myDoc.value;
    }
    return false;
  }

  @override
  int get hashCode => (this.name + this.branch.myDoc.value.path).hashCode;
}
