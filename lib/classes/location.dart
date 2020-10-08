import 'package:cloud_firestore/cloud_firestore.dart';

class Location{
  String locality,city,state,country;
  GeoPoint latLong;

  Location(this.locality, this.city, this.state, this.country,this.latLong);

  Location.fromJson(Map<String,dynamic> j){
    this.locality = j["locality"];
    this.city = j["city"];
    this.state = j["state"];
    this.country = j["country"];
    this.latLong = j["latlong"];
  }

  Map<String,dynamic> toMap(){
    return {
      "locality":this.locality,
      "city":this.city,
      "state":this.state,
      "country":this.country,
      "latlong":this.latLong,
    };
  }

  Location.update(Location oldLocation,{String locality,String city,String state,String country,GeoPoint latLong}){
    this.locality = locality??oldLocation.locality;
    this.city = city??oldLocation.city;
    this.state = state??oldLocation.state;
    this.country = country??oldLocation.country;
    this.latLong = latLong??oldLocation.latLong;
  }

  @override
  String toString(){
    return '''
    $locality\n$city\n$state\n$country\n${latLong.toString()}
    ''';
  }
}