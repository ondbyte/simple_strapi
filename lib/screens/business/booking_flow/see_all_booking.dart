import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/widgets/tiles/customer_booking_tile.dart';
import 'package:bapp/widgets/tiles/see_all_tile.dart';
import 'package:flutter/material.dart';

import 'booking_details.dart';

class BookingsSeeAllTile extends StatelessWidget {
  final String title;
  final EdgeInsets padding, titlePadding, childPadding;
  final List<BusinessBooking> bookings;

  const BookingsSeeAllTile(
      {Key key,
        this.bookings,
        this.title = "",
        this.padding,
        this.titlePadding,
        this.childPadding})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return SizedBox();
    }
    return SeeAllListTile(
      title: title,
      onSeeAll: () {
        BappNavigator.push(
          context,
          AllBookingsScreen(
            bookings: bookings,
          ),
        );
      },
      itemCount: bookings.length,
      padding: padding,
      titlePadding: titlePadding,
      childPadding: childPadding,
      itemBuilder: (_, i) {
        return BookingTile(
          booking: bookings[i],
          isCustomerView: false,
          onTap: () {
            BappNavigator.push(
              context,
              BookingDetailsScreen(
                booking: bookings[i],
                isCustomerView: false,
              ),
            );
          },
        );
      },
    );
  }
}

class AllBookingsScreen extends StatefulWidget {
  final List<BusinessBooking> bookings;

  const AllBookingsScreen({Key key, this.bookings}) : super(key: key);
  @override
  _AllBookingsScreenState createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends State<AllBookingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All bookings"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: widget.bookings.length,
        itemBuilder: (_, i) {
          return BookingTile(
            booking: widget.bookings[i],
            isCustomerView: false,
            onTap: () {
              BappNavigator.push(
                context,
                BookingDetailsScreen(
                  booking: widget.bookings[i],
                  isCustomerView: false,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
