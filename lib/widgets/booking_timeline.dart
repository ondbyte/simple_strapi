import 'package:bapp/stores/booking_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:provider/provider.dart';

class BookingTimeLineWidget extends StatefulWidget {
  final DateTime date;

  const BookingTimeLineWidget({Key key, this.date}) : super(key: key);
  @override
  _BookingTimeLineWidgetState createState() => _BookingTimeLineWidgetState();
}

class _BookingTimeLineWidgetState extends State<BookingTimeLineWidget> {
  final _c = DayViewController(zoomCoefficient: 2.0, minZoom: 2.0);
  @override
  Widget build(BuildContext context) {
    final list = flow.getMyBookingsForDay(widget.date);
    return DayView(
      date: widget.date,
      inScrollableWidget: true,
      userZoomable: false,
      controller: _c,
      events: [
        ...List.generate(
          list.length,
          (index) => FlutterWeekViewEvent(
            title: "At " + list[index].branch.name.toString(),
            description: "",
            start: list[index].fromToTiming.from,
            end: list[index].fromToTiming.to,
          ),
        )
      ],
    );
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);
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
