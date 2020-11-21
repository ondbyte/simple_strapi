import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/classes/firebase_structures/business_timings.dart';
import 'package:bapp/config/config.dart';
import 'package:flutter/material.dart';

class CustomerBookingTile extends StatelessWidget {
  final BorderRadius borderRadius;
  final BusinessBooking booking;

  const CustomerBookingTile({Key key, this.borderRadius, this.booking}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return ListTile(
      t
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius??BorderRadius.zero,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16),
      child: Row(
        children: [
          Container(
            width: 8,
          ),
          Column
        ],
      ),
    );
  }

  Color _getColor(){
    final status = booking.status;
    switch (status) {
      case BusinessBookingStatus.accepted:
      case BusinessBookingStatus.ongoing:{
        return CardsColor.colors["teal"];
      }
      case BusinessBookingStatus.pending:{
        return CardsColor.colors["purple"];
      }
      case BusinessBookingStatus.cancelledByUser:{
        return CardsColor.colors["orange"];
      }
      case BusinessBookingStatus.cancelledByManager:
      case BusinessBookingStatus.cancelledByReceptionist:
      case BusinessBookingStatus.cancelledByStaff:
      case BusinessBookingStatus.noShow:{
        return Colors.redAccent;
      }
      case BusinessBookingStatus.finished:{
        return Colors.grey[400];
      }
    }
  }
}

