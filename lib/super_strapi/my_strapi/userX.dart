import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:simple_strapi/simple_strapi.dart';

class UserX {
  final x = UserX._x();

  UserX._x();

  User _user;
  bool get hasUser => _user != null;

  Future<User> login(String firebaseToken, String email, String name) async {
    if (hasUser) {
      return _user;
    }
    Strapi.i.shouldUseHttps = true;
    final response = await Strapi.i.authenticateWithFirebaseToken(
        firebaseProviderToken: firebaseToken, email: email, name: name);
    if (response.failed) {
      return null;
    }
    _user = User.fromMap(response.body.first);
    return _user;
  }
}
