import 'package:bapp/helpers/helper.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final Function(Booking)? onTap;
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
  final dateFormatter = DateFormat.yMd();
  @override
  Widget build(BuildContext context) {
    final color = Colors.greenAccent;
    return Padding(
      padding: widget.margin ?? EdgeInsets.all(8),
      child: TapToReFetch<Booking?>(
          fetcher: () => Bookings.findOne(widget.booking.id!),
          onErrorBuilder: (_, e, s) {
            bPrint(e);
            bPrint(s);
            return ErrorTile(message: "Something is wrong tap to refresh");
          },
          onLoadBuilder: (_) => LoadingWidget(),
          onSucessBuilder: (context, booking) {
            return Bookings.listenerWidget(
                strapiObject: booking!,
                builder: (context, b, loading) {
                  return GestureDetector(
                    onTap: () {
                      widget.onTap?.call(booking);
                    },
                    child: RenderAfterChildWidget(
                      onChildRendered: (s) {
                        if (s != null) {
                          return SizedBox.fromSize(
                            size: s,
                            child: Padding(
                              padding: widget.padding ?? EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    EnumToString.convertToString(
                                        widget.booking.bookingStatus),
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
                          borderRadius:
                              widget.borderRadius ?? BorderRadius.circular(6),
                        ),
                        child: ListTile(
                          contentPadding: widget.padding ??
                              const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                          trailing: const SizedBox(
                            width: 4,
                          ),
                          title: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getOnForTime(booking.bookingStartTime!),
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              Text(
                                widget.isCustomerView
                                    ? booking.business?.name ??
                                        "no business name, inform yadu"
                                    : booking.bookedByUser?.name ??
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
                                getProductsDurationString(booking.products!) +
                                    ", " +
                                    getProductsCostString(booking.products!) +
                                    " ",
                                style: Theme.of(context).textTheme.overline,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
