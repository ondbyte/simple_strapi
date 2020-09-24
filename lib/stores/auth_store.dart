import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  @observable
  AuthStatus status = AuthStatus.unsure;
  @observable
  User user;

  @action
  Future init() async {
    var auth = FirebaseAuth.static();

    auth.userChanges().listen((u) {
      status = AuthStatus.userPresent;
      user = u;
    });
    user = auth.currentUser;
    if(user!=null){
      status = AuthStatus.userPresent;
    } else {
      status = AuthStatus.userNotPresent;
    }
  }
}

enum AuthStatus{
  unsure,
  userPresent,
  userNotPresent
}