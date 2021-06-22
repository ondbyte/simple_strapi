import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_strapi/simple_strapi.dart';

Future main() async {
  test('getNonReviewedBookingsForUser', () async {
    await run();
  });
}

Future run() async {
  Strapi.i.verbose = true;
  //final r = await i.getNonReviewedBookingsForUser();
  //print(r);
}
