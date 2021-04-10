import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../classes/firebase_structures/business_booking.dart';
import '../../stores/cloud_store.dart';
import '../size_provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BookingTile extends StatefulWidget {
  final BorderRadius? borderRadius;
  final Booking booking;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Function()? onTap;
  final bool isCustomerView;

  const BookingTile(
      {Key? key,
      this.borderRadius,
      required this.booking,
      this.padding,
      this.margin,
      this.onTap,
      this.isCustomerView = true})
      : super(key: key);

  @override
  _BookingTileState createState() => _BookingTileState();
}

class _BookingTileState extends State<BookingTile> {
  @override
  Widget build(BuildContext context) {
    final color = Colors.greenAccent;
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: widget.margin ?? EdgeInsets.all(8),
        child: RenderAfterChildWidget(
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
                        "inform yadu",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            ?.apply(color: color),
                      )
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
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
                    widget.booking.bookingStartTime?.toIso8601String() ?? "",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    widget.isCustomerView
                        ? widget.booking.business?.name ??
                            "no business name, inform yadu"
                        : widget.booking.bookedByUser?.name ??
                            "no user name, inform yadu",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.booking.products
                            ?.map((e) => e.nameOverride)
                            .join(", ") ??
                        "no products",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    "0 Minutes, " + "CUR" + " " + "total",
                    style: Theme.of(context).textTheme.overline,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
