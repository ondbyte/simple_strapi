import 'dart:async';

import 'package:bapp/classes/firebase_structures/bapp_user.dart';
import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:the_country_number/the_country_number.dart';

import '../classes/firebase_structures/business_branch.dart';
import '../classes/firebase_structures/business_category.dart';
import '../classes/firebase_structures/business_details.dart';
import '../classes/firebase_structures/business_services.dart';
import '../classes/firebase_structures/favorite.dart';
import '../classes/location.dart';
import '../config/config_data_types.dart';
import '../config/constants.dart';
import '../fcm.dart';
import '../helpers/helper.dart';
import 'all_store.dart';
import 'business_store.dart';

part 'cloud_store.g.dart';

class CloudStore = _CloudStore with _$CloudStore;

abstract class _CloudStore with Store {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  Map<String, dynamic> myData = {};
  final List<ReactionDisposer> _disposers = [];

  @observable
  List<Country> countries;

  @observable
  BappUser bappUser;

  Function _onLogin, _onNotLogin;

  @observable
  AuthStatus status = AuthStatus.unsure;
  @observable
  bool loadingForOTP = false;
  final favorites = ObservableList<Favorite>();

  AllStore _allStore;

  void setAllStore(AllStore allStore) => _allStore = allStore;

  Future init({Function onLogin, Function onNotLogin}) async {
    _onLogin = onLogin;
    _onNotLogin = onNotLogin;
    _listenForUserChange();
  }

  Future _init() async {
    await getUserData();
    await getActiveCountries();
    await getMyFavorites();
    _setupAutoRun();
  }

  BusinessBookingStatus getCancelTypeForUserType() {
    switch (bappUser.userType.value) {
      case UserType.customer:
        {
          return BusinessBookingStatus.cancelledByUser;
        }
      case UserType.businessStaff:
        {
          return BusinessBookingStatus.cancelledByStaff;
        }
      case UserType.businessReceptionist:
        {
          return BusinessBookingStatus.cancelledByReceptionist;
        }
      case UserType.manager:
      default:
        {
          return BusinessBookingStatus.cancelledByManager;
        }
    }
  }

  String getAddressLabel() {
    return (isNullOrEmpty(bappUser.address.locality)
        ? bappUser.address.city
        : bappUser.address.locality);
  }

  User get user => FirebaseAuth.instance.currentUser;

  var lastUid = "";

  void _listenForUserChange() {
    FirebaseAuth.instance.userChanges().listen((user) async {
      Helper.bPrint("user change: $user");
      if (user != null) {
        if (lastUid != user.uid || lastUid.isEmpty) {
          lastUid = user.uid;
          await _init();
        }
        if (bappUser == null) {
          return;
        }
        if (user.isAnonymous) {
          status = AuthStatus.anonymousUser;
        } else {
          status = AuthStatus.userPresent;
          bappUser = bappUser?.updateWith(
              email: user.email,
              name: user.displayName,
              theNumber: TheCountryNumber()
                  .parseNumber(internationalNumber: user.phoneNumber));
          bappUser?.save();
          _allStore.get<EventBus>().fire(bappUser);
        }
        if (_onLogin != null) {
          _onLogin();
          _onLogin = null;
        }
      } else {
        status = AuthStatus.userNotPresent;
        if (_onNotLogin != null) {
          _onNotLogin();
          _onNotLogin = null;
        }
      }
    });
  }

  Future destroyAnonymous({String uid = ""}) async {
    if (isNullOrEmpty(uid)) {
      return;
    }
    await FirebaseFirestore.instance.collection("users").doc(uid).delete();
  }

  GeoPoint getLatLongForAddress(Address address) {
    var ret = GeoPoint(0, 0);
    countries.forEach(
      (country) {
        country.cities.forEach(
          (city) {
            if (city.name == address.city && country.iso2 == address.iso2) {
              final local = city.localities.firstWhere(
                  (loc) => loc.name == address.locality,
                  orElse: () => null);
              if (local != null) {
                ret = local.latLong;
              } else {
                ret = city.localities.first.latLong;
              }
            }
          },
        );
      },
    );
    return ret;
  }

  StreamSubscription userSubscription;

  Future getUserData() async {
    final completer = Completer<bool>();
    var ref =
        await _fireStore.doc("users/${FirebaseAuth.instance.currentUser.uid}");
    myData = {};
    final snap = await ref.get();
    if (!snap.exists) {
      myData = {};
      final tmp = BappUser(
        myDoc: ref,
      );
      Helper.bPrint("the user document doesnt exists/ new user");
      await tmp.save();
      ref = tmp.myDoc;
      completer.cautiousComplete(true);
    }
    userSubscription = ref.snapshots().listen(
      (snap) async {
        if (snap.exists) {
          bappUser = BappUser.fromSnapShot(snap: snap);
          myData = snap.data() ?? {};
          completer.cautiousComplete(true);
        } else {
          userSubscription.cancel();
        }
      },
    );
    return completer.future;
  }

  @computed
  TheNumber get theNumber {
    final tmp = TheCountryNumber().parseNumber(
        internationalNumber: FirebaseAuth.instance.currentUser.phoneNumber);
    if (tmp == null) {
      return TheCountryNumber().parseNumber(iso2Code: bappUser.address.iso2);
    }
    return tmp;
  }

  @action
  Future<bool> switchUserType(BuildContext context) async {
    final businessStore = Provider.of<BusinessStore>(context, listen: false);
    if (businessStore.business == null) {
      await businessStore.getMyBusiness();
    }
    if (bappUser.userType.value != UserType.customer) {
      bappUser = bappUser.updateWith(
          userType: UserType.customer, alterEgo: bappUser.userType.value);
      await bappUser.save();
      _allStore.get<EventBus>().fire(AppEvents.reboot);
      return true;
    }
    await Future.forEach<BusinessBranch>(businessStore.business.branches.value,
        (element) async {
      await element.pull();
    });
    final anyDraft = businessStore.business.anyBranchInDraft();
    if (businessStore.business != null &&
        (anyDraft ||
            businessStore.business.anyBranchInPublished() ||
            businessStore.business.anyBranchInUnPublished())) {
      final tmp = bappUser.userType.value;
      bappUser =
          bappUser.updateWith(userType: bappUser.alterEgo.value, alterEgo: tmp);
      _allStore.get<EventBus>().fire(AppEvents.reboot);
      updateUser();
      return true;
    } else {
      Flushbar(
        message: "Your business or any of your branch is not approved yet",
        duration: Duration(seconds: 2),
      ).show(context);
      updateUser();
      return false;
    }
  }

  Future updateUser({BappUser user}) async {
    if (user != null) {
      await user.save();
    } else {
      await bappUser.save();
    }
  }

  Future getMyFavorites() async {
    if (myData.containsKey("favorites")) {
      final fs = myData["favorites"];
      if (fs is Map) {
        favorites.clear();
        for (final entry in fs.entries) {
          {
            final key = entry.key;
            final type = EnumToString.fromString(
              FavoriteType.values,
              entry.value["type"],
            );
            var business;
            var branch;
            var service;
            if (type == FavoriteType.business) {
              business = await getBusiness(reference: entry.value["business"]);
            } else if (type == FavoriteType.businessBranch) {
              branch =
                  await getBranch(reference: entry.value["businessBranch"]);
            } else if (type == FavoriteType.businessService) {
              service =
                  null; //BusinessService.fromJson(entry.value["businessService"]);
            }
            if ((business != null && business.valid) ||
                (branch != null && branch.valid) ||
                service != null) {
              favorites.add(
                Favorite(
                  id: key,
                  type: type,
                  business: business,
                  businessBranch: branch,
                  businessService: service,
                ),
              );
            }
          }
        }
      }
    }
  }

  void addOrRemoveFavorite(Favorite f) {
    final existing =
        favorites.firstWhere((element) => element == f, orElse: () => null);
    if (existing != null) {
      favorites.remove(existing);
    } else {
      favorites.add(f);
    }
    _saveFavorites();
  }

  bool isFavorite(Favorite f) {
    return favorites.any((element) => element == f);
  }

  Future _saveFavorites() async {
    final data = Map.fromEntries(favorites.map(
        (element) => MapEntry(element.id ?? kUUIDGen.v1(), element.toMap())));
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({"favorites": data});
  }

  @action
  Future getActiveCountries() async {
    var countriesCollection = _fireStore.collection("active_countries");
    var countriesDocs =
        await countriesCollection.where("enabled", isEqualTo: true).get();
    countries = [];

    countriesDocs.docs.toList().forEach(
      (element) {
        countries.add(Country.fromJson(element.data()));
      },
    );
    //activeCountries = map((e) => e.id);
  }

  void _setupAutoRun() {
    _disposers.add(
      reaction(
        (_) => BappFCM().fcmToken.value,
        (val) async {
          if (val != null && bappUser != null) {
            bappUser = bappUser.updateWith(fcmToken: val);
            bappUser.save();
          }
        },
        fireImmediately: true,
      ),
    );
  }

  Future updateProfile(
      {String displayName,
      String email,
      @required Function(FirebaseAuthException) onFail,
      @required Function() onSuccess}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user.displayName != displayName) {
      await user.updateProfile(displayName: displayName);
    }
    //Helper.printLog(email.toUpperCase());
    if (user.email == null || user.email != email) {
      try {
        await user.updateEmail(email);
        await onSuccess();
      } on FirebaseAuthException catch (e) {
        onFail(e);
      }
    }
  }

  Future loginOrSignUpWithNumber({
    TheNumber number,
    Function onVerified,
    Function(FirebaseAuthException) onFail,
    Future<String> Function(bool) onAskOTP,
    Function onResendOTPPossible,
  }) async {
    loadingForOTP = false;
    await _auth.verifyPhoneNumber(
      phoneNumber: number.internationalNumber,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
        Helper.bPrint("auto verified OTP");
        await _processCredential(
            phoneAuthCredential, number.internationalNumber);
        onVerified();
      },
      verificationFailed: (FirebaseAuthException exception) {
        onVerified = null;
        onFail(exception);
        Helper.bPrint(exception);
      },
      codeSent: (String verificationID, int resendToken) async {
        var askAgain = false;
        await Future.doWhile(
          () async {
            var otp = await onAskOTP(askAgain);
            askAgain = true;
            loadingForOTP = true;
            PhoneAuthCredential phoneAuthCredential =
                PhoneAuthProvider.credential(
                    verificationId: verificationID, smsCode: otp);
            final linked = await _processCredential(
                phoneAuthCredential, number.internationalNumber);
            //Helper.printLog(linked.toString());
            if (linked) {
              _mergePreviousData();
              onVerified();
            } else {
              loadingForOTP = false;
            }
            return !linked;
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<bool> _processCredential(
      PhoneAuthCredential phoneAuthCredential, String number) async {
    if (await _userNumberExists(number)) {
      return signIn(phoneAuthCredential);
    }
    final linked = await _link(phoneAuthCredential);
    if (linked) _mergePreviousData();
    return linked;
  }

  Future _mergePreviousData() async {
    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.phoneNumber)
        .get();
    if (!snap.exists) {
      return;
    }
    final user = BappUser.fromSnapShot(snap: snap);
    final newUser = user.updateWith(
      myDoc: BappUser.newReference(
        docName: FirebaseAuth.instance.currentUser.uid,
      ),
      address: bappUser.address,
      fcmToken: bappUser.fcmToken,
    );
    await snap.reference.delete();
    await newUser.save();
  }

  Future<bool> _userNumberExists(String number) async {
    final fun =
        FirebaseFunctions.instance.httpsCallable("checkUserForPhoneNumber");
    final rep = await fun.call({"number": "$number"});
    final data = rep.data;
    if (data is Map) {
      if (data.containsKey("success")) return true;
    }
    return false;
  }

  Future<bool> _link(PhoneAuthCredential phoneAuthCredential) async {
    try {
      await _auth.currentUser.linkWithCredential(phoneAuthCredential);
      return true;
    } on FirebaseAuthException catch (e) {
      //Helper.printLog("359" + e.code);
      print(e);
      if (e.code.toLowerCase() == "credential-already-in-use") {
        await destroyAnonymous(uid: FirebaseAuth.instance.currentUser.uid);
        await FirebaseAuth.instance.currentUser.delete();
        return await signIn(phoneAuthCredential);
      } else if (e.code.toLowerCase() == "invalid-verification-code") {
        return false;
      } else if (e.message.contains("User has already been linked")) {
        await destroyAnonymous(uid: FirebaseAuth.instance.currentUser.uid);
        await FirebaseAuth.instance.currentUser.delete();
        return await signIn(phoneAuthCredential);
      }
    }
    return false;
  }

  Future<bool> signIn(PhoneAuthCredential phoneAuthCredential) async {
    try {
      await _auth.signInWithCredential(phoneAuthCredential);
      return true;
    } on FirebaseAuthException catch (e) {
      //Helper.printLog("374" + e.code);
      print(e);
      if (e.code.toLowerCase() == "invalid-verification-code") {
        return false;
      }
    }
    return false;
  }

  Future signInAnonymous() async {
    status = AuthStatus.unsure;
    var auth = FirebaseAuth.instance;
    await auth.signInAnonymously();
  }

  @action
  Future signOut() async {
    if (FirebaseAuth.instance.currentUser.isAnonymous) {
      return;
    }
    await FirebaseAuth.instance.signOut();
    //await FirebaseAuth.instance.signInAnonymously();
  }

  final branches = <DocumentReference, BusinessBranch>{};
  final businesses = <DocumentReference, BusinessDetails>{};

  Future<BusinessBranch> getBranch(
      {DocumentReference reference, DocumentSnapshot forSnapShot}) async {
    if (forSnapShot != null) {
      final businessRef = forSnapShot["business"];
      final business = await getBusiness(reference: businessRef);
      if (business.notValid) {
        return NotBusinessBranch();
      }
      final branch =
          BusinessBranch.fromSnapShot(forSnapShot, business: business);
      if (branch.valid) {
        branches.addAll({forSnapShot.reference: branch});
      }
      return branch;
    }
    if (branches.containsKey(reference)) {
      return branches[reference];
    }
    if (reference == null) {
      return NotBusinessBranch();
    }
    final snap = await reference.get();
    if (snap.exists) {
      final businessRef = snap.data()["business"];
      final business = await getBusiness(reference: businessRef);
      if (business.notValid) {
        return NotBusinessBranch();
      }
      final branch = BusinessBranch.fromSnapShot(snap, business: business);
      if (branch.valid) {
        branches.addAll({reference: branch});
      }
      return branch;
    }
    return NotBusinessBranch();
  }

  Future<BusinessDetails> getBusiness(
      {DocumentReference reference, Map<String, dynamic> forData}) async {
    final completer = Completer<BusinessDetails>();

    if (forData != null) {
      final business = BusinessDetails.fromJson(forData);
      if (business.valid) {
        businesses.addAll({reference: business});
      }
      completer.complete(business);
    } else if (businesses.containsKey(reference)) {
      return businesses[reference];
    } else {
      final snap = await reference.get();
      final data = snap.data();
      final business = BusinessDetails.fromJson(data);
      if (business.valid) {
        businesses.addAll({reference: business});
      }
      completer.complete(business);
    }

    return completer.future;
  }

  Future<List<BusinessBranch>> getNearestFeatured() async {
    final collec = FirebaseFirestore.instance.collection("businesses");
    var query =
        collec.where("assignedAddress.iso2", isEqualTo: bappUser.address.iso2);
    if (!isNullOrEmpty(bappUser.address.locality)) {
      query = query.where(
        "assignedAddress.locality",
        isEqualTo: bappUser.address.locality,
      );
    }
    query = query
        .where("status", isEqualTo: "published")
        .where("assignedAddress.city", isEqualTo: bappUser.address.city);
    final snaps = await query.get();
    final _branches = <BusinessBranch>[];
    if (snaps.docs.isNotEmpty) {
      await Future.forEach<QueryDocumentSnapshot>(snaps.docs, (doc) async {
        final branch = await getBranch(forSnapShot: doc);
        if (branch.valid) {
          _branches.add(branch);
        }
      });
    }
    return _branches;
  }

  Future<List<BusinessBranch>> getBranchesForCategory(
      BusinessCategory category) async {
    final query = await FirebaseFirestore.instance
        .collection("businesses")
        .where("status", isEqualTo: "published")
        .where("businessCategory.name", isEqualTo: category.name)
        .where("assignedAddress.iso2", isEqualTo: bappUser.address.iso2)
        .where("assignedAddress.city", isEqualTo: bappUser.address.city);
    if (bappUser.address.locality != null) {
      query.where(
        "assignedAddress.locality",
        isEqualTo: bappUser.address.locality,
      );
    }
    final snaps = await query.get();
    if (snaps.docs.isEmpty) {
      return [];
    }
    final list = <BusinessBranch>[];
    await Future.forEach<DocumentSnapshot>(snaps.docs, (snap) async {
      final branch = await getBranch(forSnapShot: snap);
      if (branch.valid) {
        list.add(branch);
      }
    });
    return list;
  }

  Future getFavorites() async {
    favorites.clear();
    if (myData.containsKey("favorites")) {
      final favoritesData = myData["favorites"];
      if (favoritesData is Map) {
        favoritesData.forEach((k, v) async {
          if (v is Map) {
            final type =
                EnumToString.fromString(FavoriteType.values, v["type"]);
            if (type == FavoriteType.business) {
              final business = await getBusiness(reference: v["business"]);
              if (business.valid) {
                favorites.add(Favorite(business: business, type: type, id: k));
              }
            } else if (type == FavoriteType.businessBranch) {
              final branch = await getBranch(reference: v["businessBranch"]);
              if (branch.valid) {
                favorites
                    .add(Favorite(businessBranch: branch, type: type, id: k));
              }
            } else if (type == FavoriteType.businessService) {
              favorites.add(Favorite(
                  businessService:
                      BusinessService.fromJson(v["businessService"]),
                  type: type,
                  id: k));
            }
          } else {
            throw Exception(
                "This should never be the case @cloudStore getFavorites()");
          }
        });
      } else {
        throw Exception(
            "This should never be the case @cloudStore getFavorites()");
      }
    }
  }

  Future<BappUser> getUserForNumber({String number}) async {
    final snaps = await FirebaseFirestore.instance
        .collection("users")
        .where("contactNumber", isEqualTo: "$number")
        .get();
    if (snaps.size == 1) {
      return BappUser.fromSnapShot(snap: snaps.docs.first);
    }
    return null;
  }
}

enum AuthStatus { unsure, userPresent, userNotPresent, anonymousUser }
