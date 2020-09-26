import 'package:bapp/stores/auth_store.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobx/mobx.dart';
import 'package:permission_handler/permission_handler.dart';

part 'location_store.g.dart';

class LocationStore = _LocationStore with _$LocationStore;

abstract class _LocationStore with Store {
  AuthStore _authStore;
  @observable
  Position currentPosition;


  Future init(AuthStore a) async {
    _authStore = a;
    await requestCurrentPosition();
  }

  @action
  Future requestCurrentPosition({bool askPermission = false}) async {
    if (askPermission) {
      if(! (await Permission.location.request().isGranted)){
        currentPosition = await getCurrentPosition();
      }
    } else {
      if(await Permission.location.isGranted){
        currentPosition = await getCurrentPosition();
      }
    }
  }

  @action
  Future getCurrentLocation() async {
    var user = _authStore.user;
    if(user==null){
      return;
    }
    //Firebas
  }
}
