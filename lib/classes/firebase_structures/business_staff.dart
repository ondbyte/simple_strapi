import 'dart:async';

import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:thephonenumber/thecountrynumber.dart';

import 'business_branch.dart';
import 'business_details.dart';

class BusinessStaff {
  UserType role;
  String name;
  DateTime dateOfJoining;
  Map<String, bool> images = {};
  final expertise = ObservableList<String>();

  BusinessBranch branch;
  BusinessDetails business;
  BusinessStaff manager;
  BusinessStaff receptionist;
  TheNumber contactNumber;
  double rating = 0;

  DocumentSnapshot _userSnap;

  BusinessStaff({
    this.role,
    this.branch,
    this.business,
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
      "business": business.myDoc.value,
      "contactNumber": contactNumber.internationalNumber,
      "images": images.keys.toList(),
      "rating": rating
    };
  }

  Future<DocumentSnapshot> _getUserSnap() async {
    final completer = Completer<DocumentSnapshot>();
    FirebaseFirestore.instance
        .collection("users")
        .where("contactNumber",
            isEqualTo: "${contactNumber.internationalNumber}")
        .snapshots()
        .listen(
      (snaps) {
        if (snaps.docs.isEmpty) {
          throw BappException(
            msg: "This should never be the case",
            whatHappened: ""
                "when we search for a staff with their phone number in users collection it shouldn't return null",
          );
        } else if (snaps.docs.length > 1) {
          throw BappException(
            msg: "This should never be the case",
            whatHappened: ""
                "when we search for a staff with their phone number in users collection it shouldn't return more than one doc",
          );
        } else {
          _userSnap = snaps.docs.first;
          if(!completer.isCompleted){
            completer.complete(_userSnap);
          }
        }
      },
    );
    return completer.future;
  }

  Future save() async {
    await branch.myDoc.value.update({"staff.$name": toMap()});
  }

  Future delete() async {
    await branch.myDoc.value.update({"staff.$name": FieldValue.delete()});
  }

  Future updateForUser() async {
    final snap = _userSnap?? (await _getUserSnap());
    if(snap.exists){
      await snap.reference.update({
        "branches.${branch.myDoc.value.id}":branch.myDoc.value
      });
    } else {
      print("user dont exist, this shouldn't be the case");
    }
  }

  Future deleteForUser() async {
    final snap = _userSnap?? (await _getUserSnap());
    if(snap.exists){
      await snap.reference.update({
        "branches.${branch.myDoc.value.id}":FieldValue.delete()
      });
    } else {
      print("user dont exist, this shouldn't be the case");
    }
  }

  void _fromJson(Map<String, dynamic> j) {
    role = EnumToString.fromString(UserType.values, j["role"]);
    name = j["name"];
    dateOfJoining = (j["dateOfJoining"] as Timestamp).toDate();
    expertise.addAll((j["expertise"] as List).map((e) => e as String).toList());
    branch =
        business.branches.value.firstWhere((b) => b.myDoc.value == j["branch"]);
    contactNumber =
        TheCountryNumber().parseNumber(internationalNumber: j["contactNumber"]);
    images = {for (var v in j["images"]) v as String: true} ?? {};
    rating = j["rating"] ?? 0;
  }

  BusinessStaff.fromJson({@required this.business, Map<String, dynamic> j}) {
    _fromJson(j);
  }

  @override
  bool operator ==(Object other) {
    if (other is BusinessStaff) {
      return this.name == other.name &&
          this.branch.myDoc.value == other.branch.myDoc.value;
    }
    return false;
  }

  @override
  int get hashCode => (this.name + this.branch.myDoc.value.path).hashCode;
}
