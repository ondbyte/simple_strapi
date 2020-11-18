import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class BappRowCalender extends StatelessWidget {
  final Map<DateTime, List> holidays;
  final Map<DateTime, List> bookings;
  final Function(DateTime, List, List) onDayChanged;
  final CalendarController controller;
  final DateTime initialDate;

  const BappRowCalender(
      {Key key,
      this.holidays,
      this.onDayChanged,
      this.initialDate,
      this.controller,
      this.bookings})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      headerStyle: HeaderStyle(
          leftChevronIcon: Icon(FeatherIcons.chevronLeft,
              color: Theme.of(context).iconTheme.color),
          rightChevronIcon: Icon(FeatherIcons.chevronRight,
              color: Theme.of(context).iconTheme.color)),
      initialCalendarFormat: CalendarFormat.week,
      availableCalendarFormats: {CalendarFormat.week: 'Week'},
      startDay: DateTime.now(),
      calendarController: controller,
      holidays: holidays,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      events: bookings,
      calendarStyle: CalendarStyle(
        todayColor: Colors.transparent,
        todayStyle: TextStyle(color: Theme.of(context).primaryColor),
        unavailableStyle: TextStyle(color: Theme.of(context).disabledColor),
        holidayStyle: TextStyle(color: Theme.of(context).disabledColor),
        weekendStyle:
            TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
        outsideDaysVisible: false,
        canEventMarkersOverflow: true,
        markersColor: Theme.of(context).accentColor,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.5),
        markersMaxAmount: 1,
      ),
      onDaySelected: (day, events, __) {
        controller.setSelectedDay(day);
        onDayChanged(day, events, __);
      },
      onVisibleDaysChanged: (_, __, ___) {},
      onCalendarCreated: (_, __, ___) {
        controller.setSelectedDay(initialDate);
      },
    );
  }
}
