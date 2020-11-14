import 'package:bapp/stores/booking_flow.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectTimeSlotScreen extends StatefulWidget {
  @override
  _SelectTimeSlotScreenState createState() => _SelectTimeSlotScreenState();
}

class _SelectTimeSlotScreenState extends State<SelectTimeSlotScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Timeslot"),
      ),
      body: Column(
        children: [_getTableCalender()],
      ),
    );
  }

  var _calendarController = CalendarController();
  Widget _getTableCalender() {
    return TableCalendar(
      headerStyle: HeaderStyle(
          leftChevronIcon: Icon(FeatherIcons.chevronLeft,
              color: Theme.of(context).iconTheme.color),
          rightChevronIcon: Icon(FeatherIcons.chevronLeft,
              color: Theme.of(context).iconTheme.color)),
      initialCalendarFormat: CalendarFormat.week,
      availableCalendarFormats: {CalendarFormat.week: 'Week'},
      calendarController: _calendarController,
      holidays: _getHildays(),
      startingDayOfWeek: StartingDayOfWeek.sunday,
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
          markersMaxAmount: 1),
      onDaySelected: (day, events, __) {
        _calendarController.setSelectedDay(day);
      },
      onVisibleDaysChanged: (_, __, ___) {},
      onCalendarCreated: (_, __, ___) {
        _calendarController.setSelectedDay(flow.timeWindow.value.from);
      },
    );
  }

  Map<DateTime, List> _getHildays() {
    return {};
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context);
}
