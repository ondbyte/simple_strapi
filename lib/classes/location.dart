class Location{
  String locality,city,state,country;

  Location(this.locality, this.city, this.state, this.country);

  Location.fromJson(String locality, Map<String,dynamic> j){
    this.locality = locality;
    this.city = j["city"];
    this.state = j["state"];
    this.country = j["country"];
  }

  Location.update(Location oldLocation,{String locality,String city,String state,String country}){
    this.locality = locality??oldLocation.locality;
    this.city = city??oldLocation.city;
    this.state = state??oldLocation.state;
    this.country = country??oldLocation.country;
  }

  @override
  String toString(){
    return '''
    $locality\n$city\n$state\n$country
    ''';
  }
}