import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/business_profile/business_profile.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class CompleteYourBookingTile extends StatelessWidget {
  final EdgeInsets? padding;

  const CompleteYourBookingTile({
    Key? key,
    this.padding,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = UserX.i.user();
    if (user is! User) {
      return SizedBox();
    }
    return Users.listenerWidget(
      strapiObject: user,
      builder: (_, booking, loading) {
        final cart = user.cart;
        if (cart is! Booking) {
          return SizedBox();
        }
        return Bookings.listenerWidget(
          strapiObject: cart,
          sync: true,
          builder: (context, booking, loading) {
            final business = booking.business!;
            if (loading) {
              return LoadingWidget();
            }
            return ListTile(
              onTap: () {
                BappNavigator.push(
                  context,
                  BusinessProfileScreen(business: business),
                );
              },
              title: Text("Continue booking for ${business.name}"),
            );
          },
        );
      },
    );
  }
}
