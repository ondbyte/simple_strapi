import 'package:bapp/classes/location.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:thephonenumber/thephonenumber.dart';

import 'auth_store.dart';
import 'business_store.dart';
import 'firebase_structures/business_branch.dart';

part 'cloud_store.g.dart';

class CloudStore = _CloudStore with _$CloudStore;

abstract class _CloudStore with Store {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  Map<String, dynamic> myData;
  List<ReactionDisposer> _disposers = [];

  @observable
  Location myLocation;
  @observable
  List<String> activeCountries;
  @observable
  List<String> activeCountriesNames;
  @observable
  Map<String, List<Location>> availableLocations;
  @observable
  UserType userType;
  @observable
  UserType alterEgo;

  User _user;

  String _previousUID = "";

  AuthStore _authStore;

  Future init(BuildContext context) async {
    await ThePhoneNumberLib.init();
    _user = _auth.currentUser;
    _authStore = Provider.of<AuthStore>(context, listen: false);
    if (_user == null) {
      throw FlutterError("this should never be the case");
    }

    _auth.userChanges().listen(
      (u) {
        _user = u;
         if(_previousUID != _user?.uid){
           _init();
         }
      },
    );

    await _init();
    _setupAutoRun();
  }

  _init() async {
    await getUserData();
    await getMytLocation();
    await getMyUserTypes();
  }

  Future getUserData() async {
    var snap = await _fireStore.doc("users/${_user.uid}").get();
    myData = snap.data() ?? {};
  }

  @computed
  ThePhoneNumber get theNumber {
    final tmp =
        ThePhoneNumberLib.parseNumber(internationalNumber: _user.phoneNumber);
    if (tmp == null) {
      return ThePhoneNumber(iso2Code: myLocation.country);
    }
    return tmp;
  }

  @action
  Future<bool> switchUserType(BuildContext context) async {
    final businessStore = Provider.of<BusinessStore>(context, listen: false);

    if (businessStore.business != null &&
        (businessStore.business.anyBusinessInDraft() ||
            businessStore.business.anyBusinessInPublished() ||
            businessStore.business.anyBusinessInUnPublished())) {
      final tmp = userType;
      userType = alterEgo;
      alterEgo = tmp;
      Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
      return true;
    } else {
      Flushbar(
        message: "Your business or any of your branch is not approved yet",
        duration: Duration(seconds: 2),
      ).show(context);
      return false;
    }
  }

  @action
  Future getMyUserTypes() async {
    if (myData.containsKey("my_user_type")) {
      userType = UserType.values[myData["my_user_type"]];
      if (myData.containsKey("my_alter_ego")) {
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
  }

  ///will auto run on change
  Future setMyUserType() async {
    var doc = _fireStore.doc("users/${_user.uid}");
    await doc.set(
      {"my_user_type": userType.index},
      SetOptions(merge: true),
    );
  }

  ///will auto run on change
  Future setMyAlterEgo() async {
    var doc = _fireStore.doc("users/${_user.uid}");
    await doc.set(
      {"my_alter_ego": alterEgo.index},
      SetOptions(merge: true),
    );
  }

  @action
  Future getMytLocation() async {
    if (myData.containsKey("my_location")) {
      var locationData = myData["my_location"];

      ///id will be name of the
      myLocation = Location.fromJson(locationData);
      //Helper.printLog(myLocation.toString());
    }
  }

  ///will run auto when the location is updated
  Future setMyLocation() async {
    var doc = _fireStore.doc("users/${_user.uid}");
    await doc.set({"my_location": myLocation.toMap()}, SetOptions(merge: true));
  }

  @action
  Future getActiveCountries() async {
    var countriesCollection = _fireStore.collection("active_countries");
    var countriesDocs = await countriesCollection.get();
    activeCountries = [];
    activeCountriesNames = [];
    countriesDocs.docs.toList().forEach(
      (element) {
        activeCountries.add(element.id);
        final name = CountryPickerUtils.getCountryByIsoCode(element.id);
        activeCountriesNames.add(
          name.name,
        );
      },
    );
    //activeCountries = map((e) => e.id);
  }

  @action
  Future getLocationsInCountry(String c) async {
    availableLocations = {};
    final country = CountryPickerUtils.getCountryByName(c);
    final locationsCollection = _fireStore.collection("locations");
    final locationsQuery =
        locationsCollection.where("country", isEqualTo: "${country.isoCode}");
    final snaps = await locationsQuery.get();
    var allLocations = snaps.docs.map((e) => Location.fromJson(e.data()));
    availableLocations = {};
    allLocations.forEach(
      (element) {
        final key = element.city;
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
