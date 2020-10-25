import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/stores/firebase_structures/business_branch.dart';
import 'package:bapp/stores/firebase_structures/business_details.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

class BusinessStaff {
  DocumentReference myDoc;
  UserType role;
  String name;
  DateTime dateOfJoining;
  final expertise = ObservableList<BusinessServiceCategory>();

  BusinessBranch branch;
  BusinessDetails business;
  BusinessStaff manager;
  BusinessStaff receptionist;
  String uid;
  String fcmToken;

  BusinessStaff({
    this.myDoc,
    this.role,
    this.branch,
    this.business,
    this.manager,
    this.receptionist,
    this.uid,
    this.fcmToken,
    this.name,
    this.dateOfJoining,
  });

  toMap() {
    return {
      "myDoc": myDoc,
      "role": EnumToString.convertToString(role),
      "name": name,
      "dateOfJoining": dateOfJoining,
      "expertise": expertise.map((element) => element.myDoc),
      "branch": branch.myDoc,
      "business": business.myDoc,
      "manager": manager.myDoc,
      "receptionist": receptionist.myDoc,
      "uid": uid,
      "fcmToken": fcmToken,
    };
  }

  _fromJson(Map<String, dynamic> j) {
    role = EnumToString.fromString(UserType.values, j["role"]);
    name = j["name"];
    dateOfJoining = j["dateOfJoining"];
    expertise.addAll(
        j["expertise"].map((e) => BusinessServiceCategory.fromDoc(myDoc: e)));
    branch = BusinessBranch(myDoc: j["branch"]);
    manager = BusinessStaff.fromDoc(business: business, myDoc: j["manager"]);
    receptionist =
        BusinessStaff.fromDoc(business: business, myDoc: j["receptionist"]);
    uid = j["uid"];
    fcmToken = j["fcmToken"];
  }

  BusinessStaff.fromDoc({@required this.myDoc, @required this.business}) {
    myDoc.get().then((value) {
      if (value.exists) {
        _fromJson(value.data());
      }
    });
  }

  BusinessStaff.fromJson(
      {@required this.myDoc, @required this.business, Map<String, dynamic> j}) {
    _fromJson(j);
  }
}
