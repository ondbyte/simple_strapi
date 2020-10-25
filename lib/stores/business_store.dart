import 'dart:typed_data';

import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:mobx/mobx.dart' show reaction;

import 'firebase_structures/business_branch.dart';
import 'firebase_structures/business_branch.dart';
import 'firebase_structures/business_branch.dart';
import 'firebase_structures/business_category.dart';
import 'firebase_structures/business_details.dart';
import 'firebase_structures/business_holidays.dart';
import 'firebase_structures/business_timings.dart';

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
      userRelatedUpdate();
    });

    _cloudStore = Provider.of<CloudStore>(context, listen: false);
    await getMyBusiness();
  }

  userRelatedUpdate() {
    businessDoc = _fireStore.doc("businesses/${_user.uid}");
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

    final firstBranchname = businessName;
    final firstBranchDoc = _fireStore
        .doc("businesses/${_user.uid}/businessBranches/$firstBranchname");

    ///create the first default timing set
    final mainBusinessTimingDoc =
        _fireStore.doc("businesses/${_user.uid}/businessTimings/main");
    final businessTimings = BusinessTimings(myDoc: mainBusinessTimingDoc);

    ///create the deafult empty services set
    final mainBusinessServicesCollec =
        _fireStore.collection("businesses/${_user.uid}/businessServices");
    final businessServices =
        BusinessServices(myCollec: mainBusinessServicesCollec.path);

    ///create the deafult empty holidays set
    final mainBusinessHolidaysCollection =
        _fireStore.collection("businesses/${_user.uid}/businessHolidays");
    final businessHolidays =
        BusinessHolidays(myCollection: mainBusinessHolidaysCollection.path);

    final ap = BusinessDetails.from(
      businessName: businessName,
      address: address,
      category: category,
      contactNumber: contactNumber,
      latlong: latlong,
      uid: FirebaseAuth.instance.currentUser.uid,
      email: FirebaseAuth.instance.currentUser.email,
      myDoc: businessDoc,
      businessTimings: businessTimings,
      businessServices: businessServices,
      businessHolidays: businessHolidays,
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
    final businessDetails =
        await _fireStore.doc("businesses/${_user.uid}").get();

    if (businessDetails.exists) {
      final data = businessDetails.data();
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
