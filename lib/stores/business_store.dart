import 'dart:async';

import 'package:bapp/classes/firebase_structures/bapp_user.dart';
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
import 'package:event_bus/event_bus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:the_country_number/the_country_number.dart';

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
  DateTime dayForTheDetails = DateTime.now();

  DocumentReference businessDoc;

  AllStore _allStore;

  void setAllStore(AllStore allStore) => _allStore = allStore;

  StreamSubscription userChangeSubscription;

  Future init() async {
    if (userChangeSubscription != null) {
      userChangeSubscription.cancel();
    }
    userChangeSubscription =
        _allStore.get<EventBus>().on<BappUser>().listen((bappUser) {
      if (bappUser != null) {
        getMyBusiness();
      }
    });

    await getMyBusiness();
  }

  @action
  Future applyForBusiness({
    String ownerName,
    GeoPoint latlong,
    String address,
    String businessName,
    String contactNumber,
    BusinessCategory category,
    String type,
    @required bool onBoard,
  }) async {
    ///create the first branch
    businessDoc = _fireStore.doc(
        "businesses/${onBoard ? contactNumber : FirebaseAuth.instance.currentUser.uid}");

    final ap = BusinessDetails.from(
      businessName: businessName,
      address: address,
      category: category,
      contactNumber: contactNumber,
      latlong: latlong,
      uid: onBoard ? "" : FirebaseAuth.instance.currentUser.uid,
      email: onBoard ? "" : FirebaseAuth.instance.currentUser.email,
      myDoc: businessDoc,
      type: type,
    );

    BappUser user;

    if (onBoard) {
      user = await _allStore
          .get<CloudStore>()
          .getUserForNumber(number: contactNumber);
      if (isNullOrEmpty(user)) {
        user = BappUser(
          branches: {},
          business: ap.myDoc.value,
          myDoc: BappUser.newReference(docName: contactNumber),
          theNumber: TheCountryNumber()
              .parseNumber(internationalNumber: contactNumber),
          userType: UserType.customer,
          alterEgo: UserType.customer,
        );
      }
    } else {
      user = _allStore.get<CloudStore>().bappUser;
    }

    final b = await user.addBranch(
      business: ap,
      branchName: businessName,
      imagesWithFiltered: {},
      pickedLocation: PickedLocation(latlong, address),
    );

    final staff = await b.addAStaff(
      dateOfJoining: DateTime.now(),
      expertise: [],
      images: {},
      role: UserType.businessOwner,
      name: ownerName,
      userPhoneNumber: TheCountryNumber().parseNumber(
        internationalNumber: ap.contactNumber.value,
      ),
    );

    user = user.updateWith(alterEgo: UserType.businessOwner);

    await b.saveBranch();

    await ap.saveBusiness();

    await user.save();

    await staff.save();

    if (!onBoard) {
      business = ap;
      _allStore.get<CloudStore>().bappUser = user;
    } else {
      user = null;
    }
  }

  @action
  Future getMyBusiness() async {
    final completer = Completer<bool>();
    final cloudStore = _allStore.get<CloudStore>();
    if (isNullOrEmpty(cloudStore.bappUser?.branches)) {
      return false;
    }
    cloudStore.bappUser.business.snapshots().listen(
      (event) async {
        final data = event.data();
        if (isNullOrEmpty(data)) {
          return;
        }
        business = BusinessDetails.fromJson(event.data());
        final filtered = business.branches.value
            .where(
              (element) => cloudStore.bappUser.branches.values
                  .any((el) => (el) == element.myDoc.value),
            )
            .toList();
        business.branches.value.clear();
        business.branches.value.addAll(filtered);
        business.selectedBranch.value = business.branches.value.firstWhere(
            (element) =>
                element.myDoc.value == cloudStore.bappUser.selectedBranch,
            orElse: () => business.branches.value.first);
        await business.selectedBranch.value.pulled;
        business.selectedBranch.value.personalizeForUser(cloudStore.bappUser);
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
