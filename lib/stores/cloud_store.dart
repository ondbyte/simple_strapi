import 'package:bapp/classes/location.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

part 'cloud_store.g.dart';

class CloudStore = _CloudStore with _$CloudStore;

abstract class _CloudStore with Store {
  AuthStore _authStore;
  FirebaseFirestore _firstore;
  Map<String, dynamic> myData;
  List<ReactionDisposer> _disposers = [];

  @observable
  Location myLocation;
  @observable
  List<String> activeCountries;
  @observable
  Map<String, List<Location>> availableLocations;
  @observable
  UserType userType;
  @observable
  UserType alterEgo;


  Future init(AuthStore a) async {
    _authStore = a;
    _firstore = FirebaseFirestore.instance;

    if(_me==null){
      throw FlutterError("this should never be the case");
    }

    await getUserData();
    await getMytLocation();
    await getMyUserTypes();
    _setupAutoRun();
  }

  Future getUserData()async{
    var snap = await _firstore.doc("users/${_me.uid}").get();
    myData = snap.data() ?? {};
  }

  @action
  Future switchUserType() async {
    final tmp = userType;
    userType = alterEgo;
    alterEgo = tmp;
  }

  @action
  Future getMyUserTypes() async {
    if(myData.containsKey("my_user_type")){
      userType = UserType.values[myData["my_user_type"]];
      if(myData.containsKey("my_alter_ego")){
        alterEgo = UserType.values[myData["my_alter_ego"]];
      } else {
        alterEgo = UserType.customer;
        setMyAlterEgo();
      }
    } else {
      alterEgo = UserType.customer;
      userType = UserType.customer;
      setMyUserType();
      setMyAlterEgo();
    }
    ///update menu items according to role
    Helper.filterMenuItems(userType, alterEgo,_authStore.status);
  }

  ///will auto run on change
  Future setMyUserType() async {
    var doc = _firstore.doc("users/${_me.uid}");
    await doc.set({"my_user_type":userType.index},SetOptions(merge: true),);
  }
  ///will auto run on change
  Future setMyAlterEgo() async {
    var doc = _firstore.doc("users/${_me.uid}");
    await doc.set({"my_alter_ego":alterEgo.index},SetOptions(merge: true),);
  }

  @action
  Future getMytLocation() async {
    if (myData.containsKey("my_location")) {
      var locationDoc = myData["my_location"];
      var location = await locationDoc.get();

      ///id will be name of the
      myLocation = Location.fromJson(locationDoc.id, location.data());
      //Helper.printLog(myLocation.toString());
    }
  }

  ///will run auto when the location is updated
  Future setMyLocation() async {
    var doc = _firstore.doc("users/${_me.uid}");
    var ref = _firstore.doc("locations/${myLocation.locality}");
    await doc.set({"my_location": ref}, SetOptions(merge: true));
  }

  @action
  Future getActiveCountries() async {
    var countriesCollection = _firstore.collection("active_countries");
    var countriesDocs = await countriesCollection.get();
    activeCountries = [];
    countriesDocs.docs.forEach((element) {activeCountries.add(element.id);});
    //activeCountries = map((e) => e.id);
  }

  @action
  Future getLocationsInCountry(String country) async {
    final locationsCollection = _firstore.collection("locations");
    final locationsQuery =
        locationsCollection.where("country", isEqualTo: "$country");
    final snaps = await locationsQuery.get();
    var allLocations = snaps.docs.map((e) => Location.fromJson(e.id, e.data()));
    availableLocations = {};
    allLocations.forEach(
      (element) {
        final key = element.state;
        if (availableLocations.containsKey(key)) {
          availableLocations[key].add(element);
        } else {
          availableLocations[key] = [element];
        }
      },
    );    
  }

  void _setupAutoRun() {
    _disposers.add(
      reaction((_) => myLocation, (_) async {
        await setMyLocation();
      }),
    );
    _disposers.add(
      reaction((_) => userType, (_) async {
        await setMyUserType();
      }),
    );
    _disposers.add(
      reaction((_) => alterEgo, (_) async {
        await setMyAlterEgo();
      }),
    );
  }

  User get _me {
    return _authStore.user;
  }

/*   @action
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
  } */

}

