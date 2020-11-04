import 'package:bapp/classes/location.dart';

import 'package:mobx/mobx.dart';

part 'search_store.g.dart';

class SearchStore = _SearchStore with _$SearchStore;

abstract class _SearchStore with Store {
  @observable
  var results = ObservableList<BusinessShop>();
}

class BusinessShop{
  final String name;
  final String address;
  final Locality locality;
  final double stars;
  final List<String> reviews;

  BusinessShop(this.name, this.address, this.locality, this.stars, this.reviews);

  BusinessShop fromJson(Map<String,dynamic> j){
    return BusinessShop(j["name"], j["address"], j["locality"], j["stars"], j["reviews"]);
  }

  Map<String,dynamic> toMap(){
    return {
      "name":name,
      "address":address,
      "locality": locality.toMap(),
      "stars":stars,
      "reviews":reviews,
    };
  }
}