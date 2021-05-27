import 'dart:async';

import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/firebaseX.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class UserX {
  static final i = UserX._x();

  UserX._x();

  final user = Rx<User?>(null);
  StrapiObjectListener? _userListener;
  bool get userPresent => user.value != null;
  bool get userNotPresent => !userPresent;

  Future<User?> init() async {
    try {
      final token = await DefaultDataX.i.getValue("token", defaultValue: "");
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
        await DefaultDataX.i.saveValue("token", "");
      }
    }
  }

  Future<User?> loginWithFirebase(
    String firebaseToken,
    String email,
    String name,
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
      user(me);
      final token = Strapi.i.strapiToken;
      if (token.isNotEmpty) {
        DefaultDataX.i.saveValue("token", "$token");
      }
      _listenForUserObject();
      return user.value;
    } on StrapiResponseException catch (_) {
      print("Unable to Authenticate with firebase for strapi");
      await FirebaseX.i.logOut();
    } on StrapiException catch (_) {
      print("user logout");
      await FirebaseX.i.logOut();
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
