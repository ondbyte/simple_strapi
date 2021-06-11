import 'dart:async';

import 'package:bapp/app.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/firebaseX.dart';
import 'package:bapp/super_strapi/my_strapi/persistenceX.dart';
import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/app/bapp_themed_app.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class UserX {
  static late UserX i;
  UserX._i();

  factory UserX() {
    final i = UserX._i();
    UserX.i = i;
    return i;
  }

  final user = Rx<User?>(null);
  StrapiObjectListener? _userListener;
  bool get userPresent => user.value != null;
  bool get userNotPresent => !userPresent;

  Future<User?> init() async {
    try {
      final token = await PersistenceX.i.getValue("token", defaultValue: "");
      if (token.isEmpty) {
        return null;
      }
      Strapi.i.strapiToken = token;
      var newUser = await Users.me(asFindOne: true);
      user(newUser);
      return user.value;
    } on StrapiResponseException catch (e) {
      if (e.response.statusCode == 401) {
        ///needs relogin
        await PersistenceX.i.saveValue("token", "");
      }
    }
  }

  Future logout() async {
    await FirebaseX.i.logOut();
    await PersistenceX.i.saveValue("token", "");
    Strapi.i.strapiToken = "";
    kBus.fire(AppEvents.reboot);
  }

  Future<User?> loginWithFirebase(
    String firebaseToken,
    String email,
    String name,
    String fcmToken,
  ) async {
    if (userPresent) {
      print("user present");
      return user.value;
    }
    try {
      final response = await Strapi.i.authenticateWithFirebaseUid(
        firebaseUid: firebaseToken,
        email: email,
        name: name,
      );
      if (response.failed) {
        throw StrapiResponseException(
          "unable to authenticateWithFirebaseUid",
          response,
        );
      }
      final me = await Users.me(asFindOne: true);
      final copied = me?.copyWIth(fcmToken: fcmToken);
      final updated = await Users.update(copied!);
      user(updated);
      final token = Strapi.i.strapiToken;
      if (token.isNotEmpty) {
        PersistenceX.i.saveValue("token", "$token");
      }
      _listenForUserObject();
      await _copyDataFromDefault();
      return user.value;
    } on StrapiResponseException catch (_) {
      print("Unable to Authenticate with firebase for strapi");
      await FirebaseX.i.logOut();
    } on StrapiException catch (_) {
      print("user logout");
      await FirebaseX.i.logOut();
    }
  }

  Future _copyDataFromDefault() async {
    final city = DefaultDataX.i.defaultData()?.city;
    final locality = DefaultDataX.i.defaultData()?.locality;

    final copied = user.value?.copyWIth(city: city, locality: locality);
    if (copied is User) {
      final updated = await Users.update(copied);
      user(updated);
    } else {
      bPrint("cannot _copyDataFromDefault");
    }
  }

  void _listenForUserObject() {
    final id = user.value?.id;
    final data = user.value?.toMap();
    if (_userListener is! StrapiObjectListener && id is String && data is Map) {
      _userListener = StrapiObjectListener(
        id: id,
        initailData: data as Map<String, dynamic>,
        listener: (map, loading) {
          final newUser = User.fromSyncedMap(map);
          if (newUser is User) {
            user(newUser);
          }
        },
      );
    }
  }

  Future<User?> getOtherUser(User? otherUser) async {
    final id = otherUser?.id;
    if (id is String) {
      final updated = await Users.findOne(id);
      if (updated is User) {
        return updated;
      }
    }
    return otherUser;
  }
}

enum UserRole {
  customer,
  facilitator,
  manager,
  partner,
  public,
  staff,
}
