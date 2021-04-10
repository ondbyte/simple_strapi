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
  bool get userPresent => user.value != null;
  bool get userNotPresent => !userPresent;

  Future<User?> init() async {
    final token = await DefaultDataX.i.getValue("token", defaultValue: "");
    if (token.isEmpty) {
      return null;
    }
    Strapi.i.strapiToken = token;
    user(await Users.me());
    return user.value;
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
        print("user failed");
        print(response);
        return null;
      }
      user(User.fromMap(response.body.first));
      final token = Strapi.i.strapiToken;
      if (token.isNotEmpty) {
        DefaultDataX.i.saveValue("token", "$token");
      }
      return user.value;
    } on StrapiException catch (_) {
      print("user logout");
      await FirebaseX.i.logOut();
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
