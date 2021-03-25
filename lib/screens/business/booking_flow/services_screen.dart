import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/booking_flow/add_customer_details.dart';
import 'package:bapp/screens/business/booking_flow/select_time_slot.dart';
import 'package:bapp/screens/business/business_profile/tabs/services_tab.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessProfileServicesScreen extends StatelessWidget {
  final Business business;

  const BusinessProfileServicesScreen({Key? key, required this.business})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        automaticallyImplyLeading: true,
      ),
      bottomNavigationBar: FutureBuilder<Booking?>(
          future: BookingX.i.getBookingInCart(),
          builder: (_, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return SizedBox();
            }
            final lastBooking = snap.data;
            if (lastBooking is! Booking) {
              return SizedBox();
            }
            return BottomPrimaryButton(
              title: "nothing",
              subTitle: "still nothing",
              label: "Add",
              onPressed: () async {},
            );
          }),
      body: BusinessProfileServicesTab(business: business),
    );
  }
}
