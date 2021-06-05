import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/booking_flow/booking_details.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BookingTimeLineWidget extends StatefulWidget {
  final Timing? timing;
  final DateTime date;
  final List<Booking> list;

  const BookingTimeLineWidget(
      {Key? key,
      required this.date,
      this.list = const [],
      required this.timing})
      : super(key: key);
  @override
  _BookingTimeLineWidgetState createState() => _BookingTimeLineWidgetState();
}

class _BookingTimeLineWidgetState extends State<BookingTimeLineWidget> {
  final _c = DayViewController(zoomCoefficient: 2.0, minZoom: 2.0);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.list;
    final timing = widget.timing;
    if (timing is! Timing) {
      return Center(
        child: Text("No timings for the day"),
      );
    }
    return DayView(
      hoursColumnStyle: HoursColumnStyle(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      style: DayViewStyle(
          headerSize: 0,
          currentTimeCircleColor: Theme.of(context).primaryColor,
          currentTimeRuleColor: Theme.of(context).primaryColor,
          backgroundRulesColor: Theme.of(context).disabledColor,
          hourRowHeight: 120,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor),
      date: widget.date,
      minimumTime: HourMinute(
          hour: widget.timing?.from?.hour ?? 0,
          minute: widget.timing?.from?.minute ?? 0),
      maximumTime: HourMinute(
          hour: widget.timing?.to?.hour ?? 0,
          minute: widget.timing?.to?.minute ?? 0),
      inScrollableWidget: true,
      userZoomable: false,
      controller: _c,
      events: [
        ...List.generate(
          list.length,
          (index) {
            final start = list[index].bookingStartTime ?? DateTime.now();
            final end = list[index].bookingEndTime ?? DateTime.now();
            return FlutterWeekViewEvent(
              eventTextBuilder: (event, _, dayView, a, b) {
                return Text(event.title);
              },
              onTap: () {
                BappNavigator.push(
                  context,
                  BookingDetailsScreen(
                    booking: list[index],
                    isCustomerView: false,
                  ),
                );
              },
              decoration: BoxDecoration(
                color: CardsColor.next(
                  uid: (list[index].bookedByUser?.username) ?? "",
                ),
              ),
              title: "By " + (list[index].bookedByUser?.name ?? ""),
              description: "",
              start: start,
              end: end,
            );
          },
        )
      ],
    );
  }
}

/*
import 'package:bapp/classes/firebase_structures/business_timings.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingTimeLineWidget extends StatefulWidget {
  @override
  _BookingTimeLineWidgetState createState() => _BookingTimeLineWidgetState();
}

class _BookingTimeLineWidgetState extends State<BookingTimeLineWidget> {
  @override
  Widget build(BuildContext context) {
    final fromTo = _getStartTime();

    return Row(
      children: [Column()],
    );
  }

  FromToTiming _getStartTime() {
    DateTime from, to;

    flow.bookings.forEach((element) {
      if (from == null) {
        from = element.fromToTiming.from;
      } else {
        if (element.fromToTiming.from.isBefore(from)) {
          from = element.fromToTiming.from;
        }
      }
      if (to == null) {
        to = element.fromToTiming.to;
      } else {
        if (element.fromToTiming.to.isAfter(to)) {
          to = element.fromToTiming.to;
        }
      }
    });
    final nineAM = TimeOfDay(hour: 9);
    if (from.toTimeOfDay().isAfter(nineAM)) {
      from = nineAM.toDateAndTime();
    }
    final ninePM = TimeOfDay(hour: 21);
    if (from.toTimeOfDay().isBefore(ninePM)) {
      from = ninePM.toDateAndTime();
    }
    if (from == null || to == null) {
      throw FlutterError("This should never be the case @booking_timeline");
    }
    return FromToTiming.fromDates(from: from, to: to);
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);
}
*/
