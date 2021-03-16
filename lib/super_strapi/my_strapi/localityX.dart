import 'dart:io';

import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:device_info/device_info.dart';
import 'package:simple_strapi/simple_strapi.dart'
    hide DefaultData, Locality, City, Country;

class LocalityX extends X {
  static final i = LocalityX._x();

  LocalityX._x();

  Future<List<Country>> getCountries({bool force = false}) async {
    return memoize("getCountries", () async {
      final countries = await Countries.findMultiple();
      return countries;
    }, force);
  }

  Future<List<City>> getCitiesOfCountry(Country country,
      {bool force = false}) async {
    return memoize(
      "getCitiesOfCountry",
      () async {
        final query = StrapiCollectionQuery(
          collectionName: City.collectionName,
          requiredFields: City.fields(),
        )
          ..whereField(
              field: City.fields.createdAt,
              query: StrapiFieldQuery.greaterThan,
              value: DateTime.now().subtract(Duration(days: 1)))
          ..whereModelField(
            field: City.fields.country,
            query: StrapiModelQuery(
              requiredFields: Country.fields(),
            )..whereField(
                field: Country.fields.id,
                query: StrapiFieldQuery.equalTo,
                value: country.id,
              ),
          )
          ..whereCollectionField(
            field: City.fields.localities,
            query: StrapiCollectionQuery(
              collectionName: Locality.collectionName,
              requiredFields: Locality.fields(),
            ),
          );

        final cities =
            Cities.executeQuery(query); //await Cities.getForListOfIDs(ids);
        return cities;
      },
      force,
    );
  }

  @override
  Future dispose() async {
    await super.dispose();
  }
}
