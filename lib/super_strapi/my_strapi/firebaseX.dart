import 'dart:async';

import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_core/firebase_core.dart';

class FirebaseX extends X {
  static final i = FirebaseX._x();
  FirebaseX._x();

  bool get userPresent => _user != null;
  bool get userNotPresent => !userPresent;

  fba.User _user;
  fba.User get firebaseUser => _user;
  StreamSubscription _userChangesSubscription;

  Future<fba.User> init() async {
    await Firebase.initializeApp();
    final completer = Completer<fba.User>();
    _userChangesSubscription =
        fba.FirebaseAuth.instance.userChanges().listen((newUser) {
      _user = newUser;
      completer.cautiousComplete(newUser);
    });
  }

  @override
  Future dispose() async {
    _userChangesSubscription.cancel();
    _user = null;
    await super.dispose();
  }
}
