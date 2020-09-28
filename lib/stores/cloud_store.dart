import 'package:bapp/classes/location.dart';
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
  FirstLaunch isFirstLaunch = FirstLaunch.unsure;


  Future init(AuthStore a) async {
    _authStore = a;
    _firstore = FirebaseFirestore.instance;

    if(_me==null){
      throw FlutterError("this should never be the case");
    }

    await getUserData();
    await getMytLocation();
    _setupAutoRun();
  }

  Future getUserData()async{
    var snap = await _firstore.doc("users/${_me.uid}").get();
    myData = snap.data() ?? {};
  }

  @action
  Future getMytLocation() async {
    if (myData.containsKey("my_location")) {
      var locationDocPath = myData["my_location"];
      var locationDoc = _firstore.doc(locationDocPath);
      var location = await locationDoc.get();

      ///id will be name of the
      myLocation = Location.fromJson(locationDoc.id, location.data());

      Helper.printLog(myLocation.toString());
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
    ///write first launch
    _disposers.add(
      reaction((_) => myLocation, (_) async {
        await setMyLocation();
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

enum FirstLaunch { yes, no, unsure }
