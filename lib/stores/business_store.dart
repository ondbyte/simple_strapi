import 'dart:async';

import 'package:bapp/classes/firebase_structures/business_category.dart';
import 'package:bapp/classes/firebase_structures/business_details.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:bapp/stores/all_store.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

import '../helpers/helper.dart';

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

  AllStore _allStore;

  void setAllStore(AllStore allStore) => _allStore = allStore;

  Future init() async {
    _user = _auth.currentUser;
    userRelatedUpdate();
    _auth.userChanges().listen((u) {
      _user = u;
      if (_user != null) {
        userRelatedUpdate();
      }
    });

    await getMyBusiness();
  }

  void userRelatedUpdate() {
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
    String type,
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
      type: type,
    );

    await ap.addABranch(
      branchName: businessName,
      imagesWithFiltered: {},
      pickedLocation: PickedLocation(latlong, address),
    );

    await ap.saveBusiness();

    _allStore.get<CloudStore>().bappUser = _allStore
        .get<CloudStore>()
        .bappUser
        .updateWith(alterEgo: UserType.businessOwner);

    _allStore.get<CloudStore>().bappUser.save();

    business = ap;
  }

  @action
  Future getMyBusiness() async {
    final completer = Completer<bool>();
    final cloudStore = _allStore.get<CloudStore>();
    if (cloudStore.bappUser.userType.value == UserType.customer) {
      return false;
    }
    if (isNullOrEmpty(cloudStore.bappUser.branches)) {
      return false;
    }
    cloudStore.bappUser.business.snapshots().listen(
      (event) {
        business = BusinessDetails.fromJson(event.data());
        final filtered = business.branches.value.where(
          (element) => cloudStore.bappUser.branches.values
              .any((el) => (el) == element.myDoc.value),
        );
        business.branches.value.clear();
        business.branches.value.addAll(filtered);
        _allStore.get<BookingFlow>().branch = business.selectedBranch.value;
        completer.cautiousComplete(true);
      },
    );
    return completer.future;
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
