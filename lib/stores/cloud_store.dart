import 'dart:async';

import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/classes/firebase_structures/business_details.dart';
import 'package:bapp/classes/location.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:thephonenumber/thephonenumber.dart';

import '../FCM.dart';
import 'all_store.dart';
import 'business_store.dart';

part 'cloud_store.g.dart';

class CloudStore = _CloudStore with _$CloudStore;

abstract class _CloudStore with Store {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  Map<String, dynamic> myData;
  List<ReactionDisposer> _disposers = [];

  @observable
  MyAddress myAddress;
  @observable
  List<Country> countries;

  @observable
  UserType userType;
  @observable
  UserType alterEgo;
  @observable
  User user;

  Function _onLogin, _onNotLogin;

  @observable
  AuthStatus status = AuthStatus.unsure;
  @observable
  bool loadingForOTP = false;

  String fcmToken = "";

  String _previousUID = "";

  AllStore _allStore;

  void setAllStore(AllStore allStore) => _allStore = allStore;

  final branches = <DocumentReference, BusinessBranch>{};
  final businesses = <DocumentReference, BusinessDetails>{};

  Future<BusinessBranch> getBranch({DocumentReference reference}) async {
    if (branches.containsKey(reference)) {
      return branches[reference];
    }
    final snap = await reference.get();
    final data = snap.data();
    final businessRef = data["business"];
    final business = await getBusiness(reference: businessRef);
    final branch = BusinessBranch.fromJson(data, business: business);
    branches.addAll({reference: branch});
    return branch;
  }

  Future<BusinessDetails> getBusiness({DocumentReference reference}) async {
    if (businesses.containsKey(reference)) {
      return businesses[reference];
    }
    final snap = await reference.get();
    final data = snap.data();
    final business = BusinessDetails.fromJson(data);
    businesses.addAll({reference: business});
    return business;
  }

  Future init({Function onLogin, Function onNotLogin}) async {
    _onLogin = onLogin;
    _onNotLogin = onNotLogin;
    _listenForUserChange();
  }

  _init() async {
    await getUserData();
    await getActiveCountries();
    await getMyAddress();
    await getMyUserTypes();
    _setupAutoRun();
  }

  _listenForUserChange() {
    _auth.userChanges().listen(
      (u) async {
        user = u;
        if (user != null) {
          if (user.isAnonymous) {
            status = AuthStatus.anonymousUser;
          } else {
            status = AuthStatus.userPresent;
          }
          if (_previousUID != user?.uid) {
            await _init();
            if (_onLogin != null) {
              _onLogin();
              _onLogin = null;
            }
          }
        } else {
          status = AuthStatus.userNotPresent;
          _previousUID = "";
          if (_onNotLogin != null) {
            _onNotLogin();
            _onNotLogin = null;
          }
        }
        Helper.printLog("user change: $user");
      },
    );
  }

  Future getUserData() async {
    var snap = await _fireStore.doc("users/${user.uid}").get();
    myData = snap.data() ?? {};
  }

  @computed
  ThePhoneNumber get theNumber {
    final tmp =
        ThePhoneNumberLib.parseNumber(internationalNumber: user.phoneNumber);
    if (tmp == null) {
      return ThePhoneNumber(iso2Code: myAddress.country.iso2);
    }
    return tmp;
  }

  @action
  Future<bool> switchUserType(BuildContext context) async {
    final businessStore = Provider.of<BusinessStore>(context, listen: false);
    await Future.forEach<BusinessBranch>(businessStore.business.branches.value,
        (element) async {
      await element.pull();
    });
    if (businessStore.business != null &&
        (businessStore.business.anyBranchInDraft() ||
            businessStore.business.anyBranchInPublished() ||
            businessStore.business.anyBranchInUnPublished())) {
      final tmp = userType;
      userType = alterEgo;
      alterEgo = tmp;
      Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
      return true;
    } else {
      Flushbar(
        message: "Your business or any of your branch is not approved yet",
        duration: Duration(seconds: 2),
      ).show(context);
      return false;
    }
  }

  @action
  Future getMyUserTypes() async {
    if (myData.containsKey("my_user_type")) {
      userType = UserType.values[myData["my_user_type"]];
      if (myData.containsKey("my_alter_ego")) {
        alterEgo = UserType.values[myData["my_alter_ego"]];
      } else {
        alterEgo = UserType.customer;
        setMyAlterEgo();
      }
    } else {
      alterEgo = UserType.customer;
      userType = UserType.customer;
      setMyUserType();
      setMyAlterEgo();
    }
  }

  ///will auto run on change
  Future setMyUserType() async {
    var doc = _fireStore.doc("users/${FirebaseAuth.instance.currentUser.uid}");
    await doc.set(
      {"my_user_type": userType.index},
      SetOptions(merge: true),
    );
  }

  ///will auto run on change
  Future setMyAlterEgo() async {
    var doc = _fireStore.doc("users/${FirebaseAuth.instance.currentUser.uid}");
    await doc.set(
      {"my_alter_ego": alterEgo.index},
      SetOptions(merge: true),
    );
  }

  Future setMyNumber() async {
    var doc = _fireStore.doc("users/${user.uid}");
    await doc.set({
      "contactNumber": theNumber?.internationalNumber,
    }, SetOptions(merge: true));
  }

  Future setMyFcmToken() async {
    var doc = _fireStore.doc("users/${user.uid}");
    await doc.set({"fcmToken": fcmToken}, SetOptions(merge: true));
  }

  @action
  Future getMyAddress() async {
    if (myData.containsKey("myAddress")) {
      var locationData = myData["myAddress"];

      countries.forEach(
        (country) {
          country.cities.forEach(
            (city) {
              if (city.name == locationData["city"] &&
                  country.iso2 == locationData["iso2"]) {
                final local = city.localities.firstWhere(
                    (loc) => loc.name == locationData["locality"],
                    orElse: () => null);
                myAddress =
                    MyAddress(locality: local, city: city, country: country);
              }
            },
          );
        },
      );
      //final myCountry = countries.firstWhere((element) => element.cities.firstWhere((el) => el.localities.firstWhere((e) => e.name==locationData["locality"]))));

      //Helper.printLog(myLocation.toString());
    }
  }

  ///will run auto when the location is updated
  Future setMyAddress() async {
    final doc = _fireStore.doc("users/${user.uid}");
    await doc.set({"myAddress": myAddress.toMap()}, SetOptions(merge: true));
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

  Future<String> getAuthorizationForStaffing(
      {ThePhoneNumber phoneNumber,
      BusinessDetails business,
      Function(BappFCMMessage) onReplyRecieved}) async {
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable(BappFunctions.sendBappMessage);
    final called = await callable
        .call(
      BappFCMMessage(
        type: BappFCMMessageType.staffAuthorizationAsk,
        title: "You are being added as a Staff",
        body: business.businessName.value +
            " is adding you as their staff, acknowledge this to authorize adding",
        to: phoneNumber.internationalNumber,
        frm: theNumber.internationalNumber,
      ).toMap(),
    )
        .catchError((e, s) {
      Helper.printLog("error from fun");
      print(e);
      print(s);
    });
    //Helper.printLog("resopnse from fun");
    //print(called.data);
    final resultString = called.data["result"];
    print(resultString);
    if (resultString == BappFunctionsResponse.multiUser) {
      Helper.printLog("multi user found at firestore/users");
    }

    if (resultString == BappFunctionsResponse.success) {
      BappFCM().listenForStaffingAuthorizationOnce((bappMessage) {
        onReplyRecieved(bappMessage);
      });
    }
    if (resultString.runtimeType == String) {
      return resultString;
    }
    return resultString["errorInfo"]["code"];
  }

  Future<void> giveAuthorizationForStaffing(BappFCMMessage message,
      {bool authorized = false}) async {
    final bappmessage = BappFCMMessage(
      to: message.frm,
      frm: theNumber.internationalNumber,
      title: "Acknowledged",
      data: {},
      body: "Acknowledged",
      click_action: "",
      type: authorized
          ? BappFCMMessageType.staffAuthorizationAskAcknowledge
          : BappFCMMessageType.staffAuthorizationAskDeny,
    );
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable(BappFunctions.sendBappMessage);
    final called = await callable.call(bappmessage.toMap());
    print(called.data);
  }

  void _setupAutoRun() {
    _disposers.add(
      reaction((_) => myAddress, (_) async {
        await setMyAddress();
      }),
    );
    _disposers.add(
      reaction((_) => userType, (_) async {
        await setMyUserType();
      }),
    );
    _disposers.add(
      reaction((_) => alterEgo, (_) async {
        await setMyAlterEgo();
      }),
    );
    _disposers.add(
      reaction((_) => theNumber, (_) async {
        if (user != null) {
          await setMyNumber();
        }
      }),
    );
    _disposers.add(
      reaction((_) => BappFCM().fcmToken.value, (val) async {
        fcmToken = val;
        await setMyFcmToken();
      }, fireImmediately: true),
    );
  }

  Future updateProfile(
      {String displayName,
      String email,
      @required Function(FirebaseAuthException) onFail,
      @required Function() onSuccess}) async {
    if (user.displayName != displayName) {
      await user.updateProfile(displayName: displayName);
    }
    //Helper.printLog(email.toUpperCase());
    if (user.email == null || user.email != email) {
      try {
        await user.updateEmail(email);
        onSuccess();
      } on FirebaseAuthException catch (e) {
        onFail(e);
      }
    } else {
      onFail(FirebaseAuthException(message: "same-email", code: "same-email"));
    }
  }

  Future loginOrSignUpWithNumber({
    PhoneNumber number,
    Function onVerified,
    Function(FirebaseAuthException) onFail,
    Future<String> Function(bool) onAskOTP,
    Function onResendOTPPossible,
  }) async {
    loadingForOTP = false;
    await _auth.verifyPhoneNumber(
      phoneNumber: number.phoneNumber,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
        onVerified();
        await _link(phoneAuthCredential);
      },
      verificationFailed: (FirebaseAuthException exception) {
        onFail(exception);
        Helper.printLog(exception);
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
            final linked = await _link(phoneAuthCredential);
            //Helper.printLog(linked.toString());
            if (linked) {
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

  Future<bool> _link(PhoneAuthCredential phoneAuthCredential) async {
    try {
      await _auth.currentUser.linkWithCredential(phoneAuthCredential);
      return true;
    } on FirebaseAuthException catch (e) {
      //Helper.printLog("359" + e.code);
      print(e);
      if (e.code.toLowerCase() == "credential-already-in-use") {
        await FirebaseFirestore.instance
            .doc("users/${FirebaseAuth.instance.currentUser.uid}")
            .delete();
        await FirebaseAuth.instance.currentUser.delete();
        return await signIn(phoneAuthCredential);
      } else if (e.code.toLowerCase() == "invalid-verification-code") {
        return false;
      } else if (e.message.contains("User has already been linked")) {
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
    if (user.isAnonymous) {
      return;
    }
    await FirebaseAuth.instance.signOut();
    //await FirebaseAuth.instance.signInAnonymously();
  }

  Future<List<BusinessBranch>> getNearestFeatured() async {
    final query = FirebaseFirestore.instance
        .collection("businesses")
        .where("status", isEqualTo: "published")
        .where("assignedAddress.iso2", isEqualTo: myAddress.country.iso2)
        .where("assignedAddress.city", isEqualTo: myAddress.city.name);
    if (myAddress.locality != null) {
      query.where("assignedAddress.locality",
          isEqualTo: myAddress.locality.name);
    }
    final snaps = await query.get();
    final _branches = <DocumentReference, BusinessBranch>{};
    if (snaps.docs.isNotEmpty) {
      await Future.forEach<QueryDocumentSnapshot>(snaps.docs, (doc) async {
        final DocumentReference businessRef = doc.data()["business"];
        if (businesses.containsKey(businessRef)) {
          if (branches.containsKey(doc.reference)) {
            final branch = await getBranch(reference: doc.reference);
            _branches.addAll({doc.reference:branch});
          } else {
            final branch = BusinessBranch.fromJson(
              doc.data(),
              business: businesses[businessRef],
            )..myDoc.value = doc.reference;
            _branches.addAll(
              {
                doc.reference: branch,
              },
            );
          }
        } else {
          final businessDetails = await getBusiness(reference: businessRef);
          _branches.addAll({
            doc.reference: BusinessBranch.fromJson(
              doc.data(),
              business: businessDetails,
            )..myDoc.value = doc.reference,
          });
        }
      });
    }
    return branches.values.toList();
  }
}

enum AuthStatus { unsure, userPresent, userNotPresent, anonymousUser }
