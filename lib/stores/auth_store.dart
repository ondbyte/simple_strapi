import 'package:bapp/helpers/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  @observable
  AuthStatus status = AuthStatus.unsure;
  @observable
  User user;
  FirebaseAuth _auth;
  @observable
  bool loadingForOTP = false;

  @action
  Future init() async {
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;

    ///listen for user updates
    _auth.userChanges().listen((u) {
      if (u != null) {
        if (u.isAnonymous) {
          status = AuthStatus.anonymousUser;
        } else {
          status = AuthStatus.userPresent;
        }
        user = u;
      }
      Helper.printLog("user change: $user");
    });

    user = _auth.currentUser;
    if (user != null) {
      if (user.isAnonymous) {
        status = AuthStatus.anonymousUser;
      } else {
        status = AuthStatus.userPresent;
      }
      //auth.signOut();
    } else {
      status = AuthStatus.userNotPresent;
    }
    //print(status);
  }

  Future updateProfile({String displayName,String email,@required Function(FirebaseAuthException) onFail,@required Function() onSuccess}) async {
    await user.updateProfile(displayName: displayName);
    try{
      await user.updateEmail(email);
      onSuccess();
    } on FirebaseAuthException catch(e) {
      onFail(e);
    }
  }

  Future loginOrSignUpWithNumber(
      {PhoneNumber number,
      Function onVerified,
      Function(FirebaseAuthException) onFail,
      Future<String> Function(bool) onAskOTP,
      Function onResendOTPPossible,}) async {
    loadingForOTP = false;
    await _auth.verifyPhoneNumber(
      phoneNumber: number.phoneNumber,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
        onVerified();
        await _link(phoneAuthCredential);
      },
      verificationFailed: (FirebaseAuthException exception) {
        onFail(exception);
        print(exception);
      },
      codeSent: (String verificationID, int resendToken) async {
        var askAgain = false;
        Future.doWhile(() async {
          var otp = await onAskOTP(askAgain);
          askAgain = true;
          loadingForOTP = true;

          PhoneAuthCredential phoneAuthCredential =
              PhoneAuthProvider.credential(
                  verificationId: verificationID, smsCode: otp);
          final linked = await _link(phoneAuthCredential);
          if(linked){
            onVerified();
          } else {
            loadingForOTP = false;
          }
          return !linked;
        },);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<bool> _link(PhoneAuthCredential phoneAuthCredential) async {
    try {
      await _auth.currentUser.linkWithCredential(phoneAuthCredential);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code.toLowerCase() == "credential-already-in-use") {
        return await signIn(phoneAuthCredential);
      } else if (e.code.toLowerCase() == "invalid-verification-code") {
        return false;
      }
    }
    return false;
  }

  Future<bool> signIn(PhoneAuthCredential phoneAuthCredential) async {
    try {
      await _auth.signInWithCredential(phoneAuthCredential);
      return true;
    } on FirebaseAuthException catch (e) {
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
}

enum AuthStatus { unsure, userPresent, userNotPresent, anonymousUser }
