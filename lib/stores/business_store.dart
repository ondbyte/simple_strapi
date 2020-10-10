import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'business_store.g.dart';

class BusinessStore = _BusinessStore with _$BusinessStore;

abstract class _BusinessStore with Store {
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  @observable
  ObservableList<BusinessCategory> categories = ObservableList();
  @observable
  var _businessApplications = ObservableList<BusinessApplication>();
  @observable
  User _user;

  Future init(BuildContext context) async {
    _auth.userChanges().listen((u) {
      _user = u;
    });
  }

  @action
  Future applyForBusiness(BusinessApplication ap) async {
    _businessApplications.add(ap);
    await _fireStore.collection("businessApplications").add(ap.toMap());
  }

  @action
  Future getMyBusinessApplications(BusinessApplication ap) async {
    _businessApplications.add(ap);
    final collec = _fireStore.collection("businessApplications");
    collec.where("uid",isEqualTo: _user.uid);
  }

  @action
  Future getCategories() async {
    final categorySnaps = await _fireStore.collection("categories").get();
    categories.clear();
    categorySnaps.docs.forEach((element) {
      categories.add(BusinessCategory(
          document: element.reference, normalName: element.id.replaceAll("_", " ")));
    });
  }
}

class BusinessApplication {
  final BusinessCategory category;
  final String businessName;
  final String contactNumber;
  final String address;
  final GeoPoint latlong;
  final String uid;

  BusinessApplication(
      {this.category,
      this.businessName,
      this.contactNumber,
      this.address,
      this.latlong,this.uid});

  BusinessApplication fromJson(Map<String, dynamic> j) {
    return BusinessApplication(
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
      "category":category.toMap(),
      "businessName": businessName,
      "contactNumber": contactNumber,
      "address": address,
      "latLong": latlong,
      "uid":uid,
    };
  }
}

class BusinessCategory {
  final DocumentReference document;
  final String normalName;

  BusinessCategory({this.normalName, this.document});

  static BusinessCategory fromJson(Map<String, dynamic> j) {
    return BusinessCategory(normalName: j["normalName"] as String, document: j["document"] as DocumentReference);
  }

  Map<String,dynamic> toMap(){
    return {
      "normalName":normalName,
      "name":document,
    };
  }
}
