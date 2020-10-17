import 'dart:typed_data';

import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:mobx/mobx.dart' show reaction;

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

    final branch = BusinessBranch.from(
      business: businessDoc,
      staff: null,
      manager: null,
      receptionist: null,
      latlong: ap.latlong.value,
      address: ap.address.value,
      name: ap.businessName.value,
      images: [kTemporaryBusinessImage],
    );
    
    final firstBranchname = ap.businessName.value;
    final firstBranchDoc = _fireStore
        .doc("businesses/${_user.uid}/businessBranches/$firstBranchname");
    
    ap.selectedBranchDoc.value = firstBranchDoc;
    
    ap.branches.value.add(branch);
    await businessDoc.set(ap.toMap());


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
      //print(data);
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
  final selectedBranchDoc = Observable<DocumentReference>(null);
  final selectedBranch = Observable<BusinessBranch>(null);

  BusinessDetails.from({
    String businessName,
    String contactNumber,
    String address,
    GeoPoint latlong,
    String uid,
    BusinessCategory category,
    List<BusinessBranch> branches,
    DocumentReference selectedBranchDoc,
  }) {
    this.category.value = category;
    this.businessName.value = businessName;
    this.contactNumber.value = contactNumber;
    this.address.value = address;
    this.latlong.value = latlong;
    this.uid.value = uid;
    this.branches.value = branches ?? [];
    this.selectedBranchDoc.value = selectedBranchDoc;
    this.selectedBranch = _getBusinessBranch(this.selectedBranchDoc);
  }

  _getBusinessBranch(DocumentReference doc){

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
    this.selectedBranchDoc.value = j["selectedBranch"];
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
      "selectedBranch": selectedBranchDoc.value,
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
  final images = Observable<List<String>>([]);
  final name = Observable<String>(null);
  final address = Observable<String>(null);
  final latlong = Observable<GeoPoint>(null);
  final staff = Observable<List<DocumentReference>>([]);
  final manager = Observable<DocumentReference>(null);
  final receptionist = Observable<DocumentReference>(null);
  final business = Observable<DocumentReference>(null);
  final myDoc = Observable<DocumentReference>(null);

  BusinessBranch.from({
    List<String> images,
    String name,
    String address,
    GeoPoint latlong,
    List<DocumentReference> staff,
    DocumentReference manager,
    DocumentReference receptionist,
    DocumentReference business,
  }) {
    this.images.value = images;
    this.name.value = name;
    this.address.value = address;
    this.latlong.value = latlong;
    this.staff.value = staff;
    this.manager.value = manager;
    this.receptionist.value = receptionist;
    this.business.value = business;
    this.myDoc.value = business.collection("businessBranches").doc(name);
  }

  BusinessBranch.fromJson(Map<String, dynamic> j) {
    this.images.value = List.castFrom(j["images"]);
    this.name.value = j["name"];
    this.address.value = j["address"];
    this.latlong.value = j["latlong"];
    this.staff.value = List.castFrom(j["staff"]);
    this.manager.value = j["manager"];
    this.receptionist.value = j["receptionist"];
    this.business.value = j["business"];
    this.myDoc.value = business.value.collection("businessBranches").doc(name.value);
  }

  Map<String, dynamic> toMap() {
    return {
      "images": images.value,
      "name": name.value,
      "address": address.value,
      "latlong": latlong.value,
      "staff": staff.value,
      "manager": manager.value,
      "receptionist": receptionist.value,
      "business": business.value,
      "myDoc":myDoc.value,
    };
  }

  Future updateImages(List<String> paths,List<Uint8List> datas) async {
    final storage = FirebaseStorage.instance;
    final auth = FirebaseAuth.instance;
    print(paths.join("\n"));
    for (var i=0;i<paths.length;i++){
      if(!paths[i].startsWith("http")){
        final ref = storage.ref().child("${auth.currentUser.uid}/${paths[i]}");
        final task = ref.putData(datas[i]);
        final snap = await task.onComplete;
        paths[i] = await snap.ref.getDownloadURL();
      }
    }

    act((){
      images.value = paths;
    });
    
    print(paths.join("\n"));
    await myDoc.value.set({"images":paths},SetOptions(merge: true));
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
