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
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_strapi/simple_strapi.dart';

void main() {
  test("countries", () async {
    final i = StrapiInit.i;
    final cs = await LocalityX.i.getCountries();
    if (cs.isNotEmpty) {
      final c = cs.first;
      Helper.printLog((await LocalityX.i.getCitiesOfCountry(c)));
    }
  });
  test("login and jwt", () async {
    final i = StrapiInit.i;
    await DefaultDataX.i.init();
    final user = await UserX.i.init();
    sPrint(user);
    expect(UserX.i.hasUser, false);
    await UserX.i.login("4aUW91LyzxYGyPHNocl4BqQWwXG2", "iam@iam.com", "yadu");
    expect(UserX.i.hasUser, true);
  });
}
