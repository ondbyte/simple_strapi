import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:mobx/mobx.dart';
import 'package:thephonenumber/thephonenumber.dart';
import 'package:bapp/helpers/extensions.dart';

class Locality {
  final String name;
  final GeoPoint latLong;
  final bool enabled;

  Locality({this.name, this.latLong, this.enabled});

  static Locality fromJson(Map<String, dynamic> j) {
    return Locality(
        name: j["name"], enabled: j["enabled"], latLong: j["latlong"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "name": this.name,
      "latlong": this.latLong,
      "enabled": this.enabled,
    };
  }

  @override
  String toString() {
    return '''
    $name\n$enabled\n${latLong.toString()}
    ''';
  }
}

class City {
  final String name;
  final bool enabled;
  final ObservableList<Locality> localities;

  City({this.name, this.enabled, this.localities});

  static City fromJson(Map<String, dynamic> j) {
    return City(
      name: j["name"],
      enabled: j["enabled"],
      localities: ObservableList()..addAll((j["localities"] as List).map(
            (e) => Locality.fromJson(e),
      ).toList()),
    );
  }

  toMap(){
    return {
      "name":name,
      "enabled":enabled,
      "localities":localities.fold<List>([], (previousValue, element){
        previousValue.add(element.toMap());
        return previousValue;
      }),
    };
  }
}

class Country {
  final String iso2;
  final bool enabled;
  final ObservableList<City> cities;

  ThePhoneNumber thePhoneNumber;

  Country({this.iso2, this.enabled, this.cities}){
    thePhoneNumber = ThePhoneNumberLib.parseNumber(iso2Code: iso2);
  }

  static Country fromJson(Map<String,dynamic> j){
    return Country(iso2: j["iso2"],enabled: j["enable"],cities: ObservableList()..addAll((j["cities"] as List).map((e) => City.fromJson(e)).toList()));
  }

  toMap(){
    return {
      "iso2":iso2,
      "enabled":enabled,
      "cities":cities.fold<List>([], (previousValue, element){
        previousValue.add(element.toMap());
        return previousValue;
      })
    };
  }
}

class MyAddress{
  final Country country;
  final City city;
  final Locality locality;

  MyAddress({this.country, this.city, this.locality});

  toMap(){
    return {
      "iso2":country.iso2,
      "city":city.name,
      "locality":locality?.name??"",
    };
  }
}

