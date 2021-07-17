import 'dart:async';

import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/authentication/create_profile.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:bapp/widgets/dialogs.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_country_number/the_country_number.dart';

class FirebaseX extends X {
  static late FirebaseX i;
  FirebaseX._i();

  factory FirebaseX() {
    final i = FirebaseX._i();
    FirebaseX.i = i;
    return i;
  }

  bool get userPresent => _user != null;
  bool get userNotPresent => !userPresent;

  fba.User? _user;
  fba.User? get firebaseUser => _user;
  late StreamSubscription _userChangesSubscription;

  Future<fba.User?> init() async {
    await Firebase.initializeApp();
    return fba.FirebaseAuth.instance.currentUser;
    /* final completer = Completer<fba.User>();
    _userChangesSubscription =
        fba.FirebaseAuth.instance.userChanges().listen((newUser) async {
      if (newUser is fba.User) {
        _newFirebaseUser(newUser);
      }
      completer.cautiousComplete(newUser);
    }); */
  }

/*   void _newFirebaseUser(fba.User user) async {
    _user = user;
    final uid = user.uid;
    final email = user.email;
    final name = user.displayName;
    if (email is! String) {
      return;
    }
    if (name is! String) {
      return;
    }
    if (uid.isEmpty) {
      return;
    }
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final u = await UserX.i.loginWithFirebase(uid, email, name, fcmToken!);
    if (u is! User) {
      bPrint("Unable to login with firebase");
    }
  } */

  Future forceUpdateUserDetailsIfDoesntExist() async {
    final fUser = fba.FirebaseAuth.instance.currentUser;
    final existingEmail = fUser?.email ?? "";
    final existingName = fUser?.displayName ?? "";
    if (existingName.isNotEmpty && existingEmail.isNotEmpty) {
      return;
    }
    var name = "", email = "";

    await Future.doWhile(() async {
      final data = await Get.to(
        CreateYourProfileScreen(name: name, email: email),
      );

      if (data is! Map) {
        await Get.bottomSheet(
          RequiredDialog(message: "We need your email and name"),
        );
        return true;
      }
      email = data["email"] as String;
      name = data["name"] as String;

      if (GetUtils.isEmail(email) && name.isNotEmpty) {
        Get.to(
          PopResistLoadingScreen(),
        );

        await updateDisplayName(name);

        try {
          await updateEmail(email);
        } on fba.FirebaseAuthException catch (e) {
          if (e.code == "email-already-in-use") {
            await Get.bottomSheet(
              RequiredDialog(
                message:
                    "The email $email is already in use, please enter a new one",
              ),
            );
            email = "";
          } else {
            rethrow;
          }
        }
        Get.back();
      } else {
        if (!GetUtils.isEmail(email)) {
          await Get.bottomSheet(
            RequiredDialog(message: "Email is not valid"),
          );
        } else if (name.isEmpty) {
          await Get.bottomSheet(
            RequiredDialog(message: "We need your name"),
          );
        }
      }
      return !(GetUtils.isEmail(email) && name.isNotEmpty);
    });
  }

  Future updateDisplayName(String name) async {
    return fba.FirebaseAuth.instance.currentUser?.updateDisplayName(name);
  }

  Future updateEmail(String email) async {
    return fba.FirebaseAuth.instance.currentUser?.updateEmail(email);
  }

  Future updateProfile(
      {required String displayName,
      required String email,
      required Function(dynamic) onFail,
      required Function() onSuccess}) async {
    if (_user?.displayName != displayName) {
      await _user?.updateProfile(displayName: displayName);
    }
    //Helper.printLog(email.toUpperCase());
    if ((_user?.email == null)) {
      try {
        await _user?.updateEmail(email);
        await onSuccess();
      } on FirebaseAuthException catch (e) {
        onFail(e);
      }
    } else {
      onFail("email-change-not-allowed");
    }
  }

  Future loginOrSignUpWithNumber({
    required TheNumber number,
    required Function? onVerified,
    required Function(FirebaseAuthException) onFail,
    required Future<String> Function(bool) onAskOTP,
    required Function onResendOTPPossible,
  }) async {
    print("FirbaseX");
    print(number);
    await fba.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: number.internationalNumber,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
        Helper.bPrint("auto verified OTP");
        await _processCredential(
            phoneAuthCredential, number.internationalNumber);
        onVerified?.call();
      },
      verificationFailed: (FirebaseAuthException exception) {
        onVerified = null;
        onFail(exception);
        Helper.bPrint(exception);
      },
      codeSent: (String verificationID, int? resendToken) async {
        var askAgain = false;
        await Future.doWhile(
          () async {
            var otp = await onAskOTP(askAgain);
            askAgain = true;
            var phoneAuthCredential = PhoneAuthProvider.credential(
              verificationId: verificationID,
              smsCode: otp,
            );
            final linked = await _processCredential(
              phoneAuthCredential as fba.PhoneAuthCredential,
              number.internationalNumber,
            );
            //Helper.printLog(linked.toString());
            if (linked) {
              onVerified?.call();
            }
            return !linked;
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<bool> _processCredential(
      fba.PhoneAuthCredential phoneAuthCredential, String number) async {
    return signIn(phoneAuthCredential);
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

  Future<bool> _link(fba.PhoneAuthCredential phoneAuthCredential) async {
    try {
      await fba.FirebaseAuth.instance.currentUser
          ?.linkWithCredential(phoneAuthCredential);
      return true;
    } on FirebaseAuthException catch (e) {
      //Helper.printLog("359" + e.code);
      print(e);
      if (e.code.toLowerCase() == "credential-already-in-use") {
        await FirebaseAuth.instance.currentUser?.delete();
        return await signIn(phoneAuthCredential);
      } else if (e.code.toLowerCase() == "invalid-verification-code") {
        return false;
      } else if (e.message?.contains("User has already been linked") ?? false) {
        await FirebaseAuth.instance.currentUser?.delete();
        return await signIn(phoneAuthCredential);
      }
    }
    return false;
  }

  Future<bool> signIn(AuthCredential phoneAuthCredential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
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

  Future logOut() async {
    await fba.FirebaseAuth.instance.signOut();
  }

  @override
  Future dispose() async {
    _userChangesSubscription.cancel();
    _user = null;
    await super.dispose();
  }
}
