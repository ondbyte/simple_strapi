import 'package:bapp/helpers/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
    await Firebase.initializeApp();
    var auth = FirebaseAuth.instance;
    ///listen for user updates
    auth.userChanges().listen((u) {
      if(u!=null){
        if(u.isAnonymous){
          status = AuthStatus.anonymous;
        } else {
          status = AuthStatus.userPresent;
        }
        user = u;
      }
      Helper.printLog("user change: $user");
    });

    user = auth.currentUser;
    if(user!=null){
      if(user.isAnonymous){
        status = AuthStatus.anonymous;
      }else {
        status = AuthStatus.userPresent;
      }
      //auth.signOut();
    } else {
      status = AuthStatus.userNotPresent;
    }
    //print(status);
  }

  Future signInAnonymous()async{
    status = AuthStatus.unsure;
    var auth = FirebaseAuth.instance;
    await auth.signInAnonymously();
  }

}

enum AuthStatus{
  unsure,
  userPresent,
  userNotPresent,
  anonymous
}