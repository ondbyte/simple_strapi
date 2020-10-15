import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/config/constants.dart';
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
  BusinessDetails business;
  @observable
  User _user;
  @observable
  DateTime dayForTheDetails = DateTime.now();

  CloudStore _cloudStore;

  Future init(BuildContext context) async {
    _user = _auth.currentUser;
    _auth.userChanges().listen((u) {
      _user = u;
    });

    _cloudStore = Provider.of<CloudStore>(context, listen: false);
    await getMyBusiness();
  }

  @action
  Future applyForBusiness(BusinessDetails ap) async {
    final businessDoc = _fireStore.doc("businesses/${_user.uid}");

    final branch = BusinessBranch(
      business: businessDoc,
      staff: null,
      manager: null,
      receptionist: null,
      latlong: ap.latlong.value,
      address: ap.address.value,
      name: ap.businessName.value,
      images: [kTemporaryBusinessImage],
    );
    ap.selectedBranch.value = branch;
    ap.branches.value.add(branch);
    await businessDoc.set(ap.toMap());

    final firstBranchname = ap.businessName.value;
    final firstBranchDoc = _fireStore
        .doc("businesses/${_user.uid}/businessBranches/$firstBranchname");

    await firstBranchDoc.set(
      branch.toMap(),
    );

    _cloudStore.alterEgo = UserType.businessOwner;

    business = ap;
  }

  @action
  Future getMyBusiness() async {
    final businessDetails =
        await _fireStore.doc("businesses/${_user.uid}").get();

    if (businessDetails.exists) {
      final data = businessDetails.data();
      final branches = (await businessDetails.reference
              .collection("/businessBranches")
              .get())
          .docs;
      data["branches"] = branches.map((e) => e.data()).toList();
      print(data);
      business = BusinessDetails.fromJson(data);
    }
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
  final category = Observable<BusinessCategory>(null);
  final Observable<String> businessName = Observable<String>(null);
  final Observable<String> contactNumber = Observable<String>(null);
  final Observable<String> address = Observable<String>(null);
  final Observable<GeoPoint> latlong = Observable<GeoPoint>(null);
  final Observable<String> uid = Observable<String>(null);
  final branches = Observable<List<BusinessBranch>>([]);
  final selectedBranch = Observable<BusinessBranch>(null);

  BusinessDetails.from({
    String businessName,
    String contactNumber,
    String address,
    GeoPoint latlong,
    String uid,
    BusinessCategory category,
    List<BusinessBranch> branches,
    BusinessBranch selectedBranch,
  }) {
    this.category.value = category;
    this.businessName.value = businessName;
    this.contactNumber.value = contactNumber;
    this.address.value = address;
    this.latlong.value = latlong;
    this.uid.value = uid;
    this.branches.value = branches ?? [];
    this.selectedBranch.value = selectedBranch;
  }

  BusinessDetails.fromJson(Map<String, dynamic> j) {
    this.category.value = BusinessCategory.fromJson(j["category"]);
    this.businessName.value = j["businessName"] as String;
    this.contactNumber.value = j["contactNumber"] as String;
    this.address.value = j["address"] as String;
    this.latlong.value = j["latlong"] as GeoPoint;
    this.uid.value = j["uid"] as String;
    final tmp = j["branches"] as List;
    if (tmp != null) {
      this.branches.value = tmp.map((e) => BusinessBranch.fromJson(e)).toList();
    }
    this.selectedBranch.value = BusinessBranch.fromJson(j["selectedBranch"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "category": category.value.toMap(),
      "businessName": businessName.value,
      "contactNumber": contactNumber.value,
      "address": address.value,
      "latLong": latlong.value,
      "uid": uid.value,
      "branches": branches.value.map((e) => e.toMap()).toList(),
      "selectedBranch": selectedBranch.value.toMap(),
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

  static BusinessBranch fromJson(Map<String, dynamic> j) {
    //print(j);
    return BusinessBranch(
        images: List.castFrom(j["images"]),
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
