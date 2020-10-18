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

import 'firebase_structures/business_branch.dart';
import 'firebase_structures/business_category.dart';
import 'firebase_structures/business_details.dart';

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
      images: [kTemporaryBusinessImageStorageRefPath],
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
    ap.getSelectedBranchDetails(firstBranchDoc);

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
