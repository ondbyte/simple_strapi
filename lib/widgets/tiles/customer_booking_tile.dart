import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerBookingTile extends StatelessWidget {
  final BorderRadius borderRadius;
  final BusinessBooking booking;

  const CustomerBookingTile({Key key, this.borderRadius, this.booking})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final currency =
        Provider.of<CloudStore>(context, listen: false).theNumber.currency;
    return ListTile(
      leading: SizedBox(
        width: 8,
        height: double.maxFinite,
        child: Container(
          color: _getColor(),
        ),
      ),
      trailing: TextButton(
        child: Text(""),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) => _getColor(),
          ),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.fromToTiming.format(),
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Text(
            booking.branch.name.value,
            style: Theme.of(context).textTheme.headline3,
          ),
        ],
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.getServicesSeperatedBycomma(),
            style: Theme.of(context).textTheme.subtitle2,
          ),
          Text(
            booking.fromToTiming.inMinutes().toString() +
                " Minutes, " +
                currency +
                " " +
                booking.totalCost().toString(),
          )
        ],
      ),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 8,
          ),
          //Column
        ],
      ),
    );
  }

  Color _getColor() {
    final status = booking.status;
    switch (status) {
      case BusinessBookingStatus.accepted:
      case BusinessBookingStatus.ongoing:
        {
          return CardsColor.colors["teal"];
        }
      case BusinessBookingStatus.pending:
        {
          return CardsColor.colors["purple"];
        }
      case BusinessBookingStatus.cancelledByUser:
        {
          return CardsColor.colors["orange"];
        }
      case BusinessBookingStatus.cancelledByManager:
      case BusinessBookingStatus.cancelledByReceptionist:
      case BusinessBookingStatus.cancelledByStaff:
      case BusinessBookingStatus.noShow:
        {
          return Colors.redAccent;
        }
      case BusinessBookingStatus.finished:
        {
          return Colors.grey[400];
        }
    }
  }

  Color _getButtonLabel() {
    final status = booking.status;
    switch (status) {
      case BusinessBookingStatus.accepted:
      case BusinessBookingStatus.ongoing:
        {
          return CardsColor.colors["teal"];
        }
      case BusinessBookingStatus.pending:
        {
          return CardsColor.colors["purple"];
        }
      case BusinessBookingStatus.cancelledByUser:
        {
          return CardsColor.colors["orange"];
        }
      case BusinessBookingStatus.cancelledByManager:
      case BusinessBookingStatus.cancelledByReceptionist:
      case BusinessBookingStatus.cancelledByStaff:
      case BusinessBookingStatus.noShow:
        {
          return Colors.redAccent;
        }
      case BusinessBookingStatus.finished:
        {
          return Colors.grey[400];
        }
    }
  }
}
