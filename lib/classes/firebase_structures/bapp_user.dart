import 'package:bapp/classes/location.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';
import 'package:thephonenumber/thecountrynumber.dart';

class BappUser {
  final DocumentReference myDoc;
  final contactNumber = Observable<TheNumber>(null);
  final fcmToken = Observable<String>("");
  final my_alter_ego = Observable<UserType>(null);
  final my_user_type = Observable<UserType>(null);
  final my_location = Observable<Locality>(null);

  BappUser({this.myDoc});

  BappUser.fromDoc({this.myDoc, bool fetch = true}) {
    if (fetch) {
      myDoc.get().then((value) {
        if (value.exists) {
          _fromJson(value.data());
        }
      });
    }
  }

  BappUser.fromJson({this.myDoc, Map<String, dynamic> j}) {
    _fromJson(j);
  }

  _fromJson(Map<String, dynamic> j) {
    contactNumber.value =TheCountryNumber().parseNumber(internationalNumber: j["contactNumber"]);
    fcmToken.value = j["fcmToken"];
    my_alter_ego.value = UserType.values[j["my_alter_ego"]];
    my_user_type.value = UserType.values[j["my_user_type"]];
    my_location.value = Locality.fromJson(j["my_location"]);
  }
}
