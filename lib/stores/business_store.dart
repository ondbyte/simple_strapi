import 'package:bapp/classes/firebase_structures/business_category.dart';
import 'package:bapp/classes/firebase_structures/business_details.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
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

  DocumentReference businessDoc;

  CloudStore _cloudStore;

  Future init(BuildContext context) async {
    _user = _auth.currentUser;
    userRelatedUpdate();
    _auth.userChanges().listen((u) {
      _user = u;
      if (_user != null) {
        userRelatedUpdate();
      }
    });

    _cloudStore = Provider.of<CloudStore>(context, listen: false);
    await getMyBusiness();
  }

  userRelatedUpdate() {
    businessDoc =
        _fireStore.doc("businesses/${FirebaseAuth.instance.currentUser.uid}");
  }

  @action
  Future applyForBusiness({
    GeoPoint latlong,
    String address,
    String businessName,
    String contactNumber,
    BusinessCategory category,
  }) async {
    ///create the first branch
    businessDoc =
        _fireStore.doc("businesses/${FirebaseAuth.instance.currentUser.uid}");

    final ap = BusinessDetails.from(
      businessName: businessName,
      address: address,
      category: category,
      contactNumber: contactNumber,
      latlong: latlong,
      uid: FirebaseAuth.instance.currentUser.uid,
      email: FirebaseAuth.instance.currentUser.email,
      myDoc: businessDoc,
    );

    await ap.addABranch(
      branchName: businessName,
      imagesWithFiltered: {},
      pickedLocation: PickedLocation(latlong, address),
    );

    await ap.saveBusiness();

    _cloudStore.alterEgo = UserType.businessOwner;

    business = ap;
  }

  @action
  Future getMyBusiness() async {
    final businessDetails = await _fireStore
        .doc("businesses/${FirebaseAuth.instance.currentUser.uid}")
        .get();

    if (businessDetails.exists) {
      final data = businessDetails.data();
      //print(data);
      business = BusinessDetails.fromJson(data);
    }
  }

  @action
  Future getCategories() async {
    final categorySnaps = await _fireStore.doc("categories/categories").get();
    categories.clear();
    categorySnaps.data().forEach((k, v) {
      categories.add(BusinessCategory.fromJson(v));
    });
  }
}
