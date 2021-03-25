// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bapp/helpers/helper.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/init.dart';
import 'package:bapp/super_strapi/my_strapi/localityX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

Future<void> main() async {
  test("countries", () async {
    final i = StrapiSettings.i;
    final cs = await LocalityX.i.getCountries();
    if (cs.isNotEmpty) {
      final c = cs.first;
      Helper.bPrint((await LocalityX.i.getCitiesOfCountry(c)));
    }
  });
  test("login and jwt", () async {
    await StrapiSettings.i.init();

    await DefaultDataX.i.init();
    final token = await DefaultDataX.i.getValue("token", defaultValue: "");
    final user = await UserX.i.init();
    sPrint(user);
    expect(UserX.i.userPresent, token != "");
    await UserX.i.loginWithFirebase(
        "4aUW91LyzxYGyPHNocl4BqQWwXG2", "iam@iam.com", "yadu");
    expect(UserX.i.userPresent, true);
  });
  final f = City.fields;

  final list = await Bookings.executeQuery(
    StrapiCollectionQuery(
      collectionName: Locality.collectionName,
      requiredFields: Locality.fields(),
    )..whereField(
        field: Locality.fields.name,
        query: StrapiFieldQuery.equalTo,
        value: "Al Barsha",
      ),
  );

  test(
    "graph query",
    () async {
      final q = StrapiCollectionQuery(
        collectionName: City.collectionName,
        requiredFields: City.fields(),
      );

      final response = await Cities.executeQuery(q);
      print(response);
    },
  );
}
