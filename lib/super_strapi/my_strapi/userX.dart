import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:simple_strapi/simple_strapi.dart';

class UserX {
  static final i = UserX._x();

  UserX._x();

  User _user;
  bool get hasUser => _user != null;
  User get user => _user;

  Future<User> init() async {
    final token = await DefaultDataX.i.getValue("token", defaultValue: "");
    if (token.isEmpty) {
      return null;
    }
    Strapi.i.strapiToken = token;
    _user = await Users.me();
    return _user;
  }

  Future<User> login(String firebaseToken, String email, String name) async {
    if (hasUser) {
      return _user;
    }
    final response = await Strapi.i.authenticateWithFirebaseToken(
        firebaseProviderToken: firebaseToken, email: email, name: name);
    if (response.failed) {
      return null;
    }
    _user = User.fromMap(response.body.first);
    final token = Strapi.i.strapiToken ?? "";
    if (token.isNotEmpty) {
      DefaultDataX.i.saveValue("token", "$token");
    }
    return _user;
  }
}
