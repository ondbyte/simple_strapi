import 'package:bapp/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../classes/firebase_structures/business_booking.dart';
import '../../stores/cloud_store.dart';
import '../size_provider.dart';

class CustomerBookingTile extends StatefulWidget {
  final BorderRadius borderRadius;
  final BusinessBooking booking;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const CustomerBookingTile(
      {Key key, this.borderRadius, this.booking, this.padding, this.margin})
      : super(key: key);

  @override
  _CustomerBookingTileState createState() => _CustomerBookingTileState();
}

class _CustomerBookingTileState extends State<CustomerBookingTile> {
  final _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final color = BusinessBooking.getColor(widget.booking.status);
    final currency =
        Provider.of<CloudStore>(context, listen: false).theNumber.country.currency;
    return Padding(
      key: _key,
      padding: widget.margin ?? EdgeInsets.all(8),
      child: RenderAfterChildWidget(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
          ),
          child: ListTile(
            contentPadding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            trailing: const SizedBox(
              width: 4,
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.fromToTiming.format(),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  widget.booking.branch.name.value,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.getServicesSeperatedBycomma(),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  widget.booking.fromToTiming.inMinutes().toString() +
                      " Minutes, " +
                      currency +
                      " " +
                      widget.booking.totalCost().toString(),
                      style: Theme.of(context).textTheme.overline,
                )
              ],
            ),
          ),
        ),
        onChildRendered: (s) {
          if (s != null) {
            return SizedBox.fromSize(
              size: s,
              child: Padding(
                padding: widget.padding ?? EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Text(
                      BusinessBooking.getButtonLabel(widget.booking.status),
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .apply(color: color),
                    )
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
