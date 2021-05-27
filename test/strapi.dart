import 'dart:io';

import 'package:bapp/super_strapi/my_strapi/localityX.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

Future main() async {
  test('city_inLocality', () async {
    final dd = await run();
    print(dd);
  });
}

Future<DefaultData?> run() async {
  final id = "4dea2f6bb596d1c4";
  Strapi.i.verbose = false;
  final b = await Businesses.findOne("609e692b12ba77000ea67fd6");
  final u = await Users.findOne("60715aabad8c81000eb38b11");
  final e = await b!.employees!.first.sync();
  final c = await Bookings.create(
    Booking.fresh(
        business: b,
        bookedByUser: u,
        bookingStatus: BookingStatus.pendingApproval,
        employee: e,
        products: [
          b.catalogue!.first.catalogueItems!.first,
        ]),
  );
  print(c);
}
