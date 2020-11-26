import 'package:bapp/config/config_data_types.dart';
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

  void _fromJson(Map<String, dynamic> j) {
    role = EnumToString.fromString(UserType.values, j["role"]);
    name = j["name"];
    dateOfJoining = (j["dateOfJoining"] as Timestamp).toDate();
    expertise.addAll((j["expertise"] as List).map((e) => e as String).toList());
    branch =
        business.branches.value.firstWhere((b) => b.myDoc.value == j["branch"]);
    contactNumber = TheNumber(internationalNumber: j["contactNumber"]);
    images = Map.fromIterable(j["images"],
            key: (v) => v as String, value: (_) => true) ??
        {};
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
