import 'dart:io';

import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:simple_strapi/simple_strapi.dart'
    hide DefaultData, Locality, City, Country;
import 'package:super_strapi_generated/super_strapi_generated.dart';

class LocalityX extends X {
  static final i = LocalityX._x();

  LocalityX._x();

  Future<List<Country>> getCountries(
      {Key key = const ValueKey("getCountries")}) async {
    return memoize(
      key,
      () async {
        final countries = await Countries.findMultiple();
        return countries;
      },
    );
  }

  Future<List<City>> getCitiesOfCountry(Country country, {Key? key}) async {
    return memoize(
      key ?? ValueKey("getCitiesOfCountry"),
      () async {
        final query = StrapiCollectionQuery(
          collectionName: City.collectionName,
          requiredFields: City.fields(),
        )
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
    );
  }

  Future<Country?> getCountryFor(
      {Locality? locality, City? city, Key? key}) async {
    return memoize(
      key ?? ValueKey("getCountryFor"),
      () async {
        final targetCity = city ?? locality?.city;
        final query = StrapiCollectionQuery(
          collectionName: Country.collectionName,
          requiredFields: Country.fields(),
        )..whereCollectionField(
            field: Country.fields.cities,
            query: StrapiCollectionQuery(
              collectionName: City.collectionName,
              requiredFields: City.fields(),
            )..whereField(
                field: City.fields.id,
                query: StrapiFieldQuery.equalTo,
                value: targetCity?.id,
              ),
          );
        final all = await Countries.executeQuery(query);
        if (all.isNotEmpty) {
          print(all);
          return all.first;
        }
      },
    );
  }

  @override
  Future dispose() async {
    await super.dispose();
  }
}
