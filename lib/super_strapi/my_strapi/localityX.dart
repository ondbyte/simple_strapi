import 'dart:io';

import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:device_info/device_info.dart';
import 'package:simple_strapi/simple_strapi.dart';

class LocalityX {
  static final i = LocalityX._x();

  LocalityX._x();

  Future<List<Country>> getCountries() async {
    final countries = await Countries.findMultiple();
    return countries;
  }

  Future<List<City>> getCitiesOfCountry(Country country) async {
    final ids = country.cities.map((e) => e.id).toList();
    final cities = await Cities.getForListOfIDs(ids);
    return cities;
  }


}
