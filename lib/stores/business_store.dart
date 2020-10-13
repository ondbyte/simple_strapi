import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

part 'business_store.g.dart';

class BusinessStore = _BusinessStore with _$BusinessStore;

abstract class _BusinessStore with Store {
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  @observable
  var categories = ObservableList<BusinessCategory>();
  @observable
  var _businessApplications = ObservableList<BusinessDetails>();
  @observable
  User _user;

  CloudStore _cloudStore ;

  Future init(BuildContext context) async {
    _auth.userChanges().listen((u) {
      _user = u;
    });

    _cloudStore = Provider.of<CloudStore>(context,listen: false);
  }

  @action
  Future applyForBusiness(BusinessDetails ap) async {
    _businessApplications.add(ap);
    final businessDoc =
        await _fireStore.collection("businesses/${_user.uid}").add(ap.toMap());

    final firstBranchname = ap.businessName;
    final firstBranchDoc = _fireStore
        .doc("businesses/${_user.uid}/businessBranches/$firstBranchname");

    await firstBranchDoc.set(
      BusinessBranch(
              business: businessDoc,
              staff: null,
              manager: null,
              receptionist: null,
              latlong: ap.latlong,
              address: ap.address,
              name: ap.businessName,
              images: null)
          .toMap(),
    );

    _cloudStore.alterEgo = UserType.businessOwner;
  }

  @action
  Future getMyBusinessApplications(BusinessDetails ap) async {
    _businessApplications.add(ap);
    final collec = _fireStore.collection("businesses/${_user.uid}");
    collec.where("uid", isEqualTo: _user.uid);
  }

  @action
  Future getCategories() async {
    final categorySnaps = await _fireStore.collection("categories").get();
    categories.clear();
    categorySnaps.docs.forEach((element) {
      categories.add(BusinessCategory(
          document: element.reference,
          normalName: element.id.replaceAll("_", " ")));
    });
  }
}

class BusinessDetails {
  final BusinessCategory category;
  final String businessName;
  final String contactNumber;
  final String address;
  final GeoPoint latlong;
  final String uid;
  final List<BusinessBranch> branches;

  BusinessDetails(
      {this.branches,
      this.category,
      this.businessName,
      this.contactNumber,
      this.address,
      this.latlong,
      this.uid});

  BusinessDetails fromJson(Map<String, dynamic> j) {
    return BusinessDetails(
      category: BusinessCategory.fromJson(j["category"]),
      businessName: j["businessName"] as String,
      contactNumber: j["contactNumber"] as String,
      address: j["address"] as String,
      latlong: j["latlong"] as GeoPoint,
      uid: j["uid"] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "category": category.toMap(),
      "businessName": businessName,
      "contactNumber": contactNumber,
      "address": address,
      "latLong": latlong,
      "uid": uid,
    };
  }
}

class BusinessStaff {
  final DocumentReference user;
  final DocumentReference comesUnderBranch;
  final DocumentReference comesUnderBusiness;
  final DocumentReference comesUnderManger;
  final DocumentReference comesUnderReceptionist;

  BusinessStaff(
      {this.user,
      this.comesUnderBranch,
      this.comesUnderBusiness,
      this.comesUnderManger,
      this.comesUnderReceptionist});
}

class BusinessManager {
  final DocumentReference user;
  final DocumentReference belongsToBusiness;
  final List<DocumentReference> maintainsBranches;

  BusinessManager({this.user, this.belongsToBusiness, this.maintainsBranches});
}

class BusinessReceptionist {
  final DocumentReference user;
  final DocumentReference belongsToBusiness;
  final DocumentReference belongsToManager;
  final DocumentReference belongsToBranch;

  BusinessReceptionist(
      {this.user,
      this.belongsToBusiness,
      this.belongsToManager,
      this.belongsToBranch});
}

class BusinessBranch {
  final List<String> images;
  final String name;
  final String address;
  final GeoPoint latlong;
  final List<DocumentReference> staff;
  final DocumentReference manager;
  final DocumentReference receptionist;
  final DocumentReference business;

  BusinessBranch(
      {this.images,
      this.name,
      this.address,
      this.latlong,
      this.staff,
      this.manager,
      this.receptionist,
      this.business});

  BusinessBranch fromJson(Map<String, dynamic> j) {
    return BusinessBranch(
        images: j["images"],
        name: j["name"],
        address: j["address"],
        latlong: j["latlong"],
        staff: j["staff"],
        manager: j["manager"],
        receptionist: j["receptionist"],
        business: j["business"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "images": images,
      "name": name,
      "address": address,
      "latlong": latlong,
      "staff": staff,
      "manager": manager,
      "receptionist": receptionist
    };
  }
}

class BusinessCategory {
  final DocumentReference document;
  final String normalName;

  BusinessCategory({this.normalName, this.document});

  static BusinessCategory fromJson(Map<String, dynamic> j) {
    return BusinessCategory(
        normalName: j["normalName"] as String,
        document: j["document"] as DocumentReference);
  }

  Map<String, dynamic> toMap() {
    return {
      "normalName": normalName,
      "name": document,
    };
  }
}
