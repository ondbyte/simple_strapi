import 'package:bapp/screens/business/business_profile/tabs/services_tab.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:flutter/material.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessProfileServicesScreen extends StatefulWidget {
  final Business business;
  BusinessProfileServicesScreen({Key? key, required this.business})
      : super(key: key);

  @override
  _BusinessProfileServicesScreenState createState() =>
      _BusinessProfileServicesScreenState();
}

class _BusinessProfileServicesScreenState
    extends State<BusinessProfileServicesScreen> {
  var getCartKey = ValueKey("getCart");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        automaticallyImplyLeading: true,
      ),
      bottomNavigationBar: TapToReFetch<Booking?>(
          fetcher: () {
            return BookingX.i.getCart();
          },
          onTap: () => getCartKey = ValueKey("getCart"),
          onLoadBuilder: (_) => LoadingWidget(),
          onErrorBuilder: (_, e, s) => ErrorTile(message: "tap to refresh"),
          onSucessBuilder: (_, booking) {
            final lastBooking = booking;
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
      body:
          SizedBox() /* BusinessProfileServicesTab(
        business: widget.business,
        onServicesSelected: (ss) {},
        cart
      ) */
      ,
    );
  }
}
