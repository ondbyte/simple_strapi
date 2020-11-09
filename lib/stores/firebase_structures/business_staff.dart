import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/stores/firebase_structures/business_branch.dart';
import 'package:bapp/stores/firebase_structures/business_details.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

class BusinessStaff {
  UserType role;
  String name;
  DateTime dateOfJoining;
  Map<String, bool> images = {};
  final expertise = ObservableList<BusinessServiceCategory>();

  BusinessBranch branch;
  BusinessDetails business;
  BusinessStaff manager;
  BusinessStaff receptionist;
  String uid;

  BusinessStaff({
    this.role,
    this.branch,
    this.business,
    this.uid,
    this.name,
    this.dateOfJoining,
    this.images = const {},
  });

  toMap() {
    return {
      "role": EnumToString.convertToString(role),
      "name": name,
      "dateOfJoining": dateOfJoining,
      "expertise": expertise.map((category) => category.toMap()),
      "branch": branch.myDoc,
      "business": business.myDoc,
      "uid": uid,
      "images": images.keys.toList(),
    };
  }

  _fromJson(Map<String, dynamic> j) {
    role = EnumToString.fromString(UserType.values, j["role"]);
    name = j["name"];
    dateOfJoining = j["dateOfJoining"];
    expertise.addAll(
        j["expertise"].map((e) => BusinessServiceCategory.fromJson(e)));
    branch = business.branches.value.firstWhere((b) => b.myDoc.value==j["branch"]);
    uid = j["uid"];
    images = Map.fromIterable(j["images"],
            key: (v) => v as String, value: (_) => true) ??
        {};
  }

  BusinessStaff.fromJson(
      {@required this.business, Map<String, dynamic> j}) {
    _fromJson(j);
  }
}
