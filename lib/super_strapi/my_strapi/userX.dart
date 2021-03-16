import 'dart:async';

import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:simple_strapi/simple_strapi.dart';

class UserX {
  static final i = UserX._x();

  UserX._x();

  Rx<User> user = Rx<User>();
  bool get userPresent => user.value != null;
  bool get userNotPresent => !userPresent;

  Future<User> init() async {
    final token = await DefaultDataX.i.getValue("token", defaultValue: "");
    if (token.isEmpty) {
      return null;
    }
    Strapi.i.strapiToken = token;
    user(await Users.me());
    return user.value;
  }

  Future<User> loginWithFirebase(
      String firebaseToken, String email, String name) async {
    if (userPresent) {
      return user.value;
    }
    final response = await Strapi.i.authenticateWithFirebaseToken(
        firebaseProviderToken: firebaseToken, email: email, name: name);
    if (response.failed) {
      return null;
    }
    user(User.fromMap(response.body.first));
    final token = Strapi.i.strapiToken ?? "";
    if (token.isNotEmpty) {
      DefaultDataX.i.saveValue("token", "$token");
    }
    return user.value;
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
