import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectTimeSlotScreen extends StatefulWidget {
  @override
  _SelectTimeSlotScreenState createState() => _SelectTimeSlotScreenState();
}

class _SelectTimeSlotScreenState extends State<SelectTimeSlotScreen> {
  var _holiday = Observable(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Timeslot"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BappRowCalender(
            controller: CalendarController(),
            holidays: flow.holidays,
            initialDate: flow.timeWindow.value.from,
            onDayChanged: (day, _, holidays) {
              if (holidays.isNotEmpty) {
                act(() {
                  _holiday.value = true;
                });
              } else {
                act(() {
                  _holiday.value = false;
                });
              }
            },
          ),
          _getTimeSlotTabs()
        ],
      ),
    );
  }

  Widget _getTimeSlotTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          getBappTabBar(context, [
            Text("Morning"),
            Text("Afternoon"),
            Text("Evening"),
          ]),
          TabBarView(children: []),
        ],
      ),
    );
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context);
}

class BappRowCalender extends StatelessWidget {
  final Map<DateTime, List> holidays;
  final Function(DateTime, List, List) onDayChanged;
  final controller;
  final DateTime initialDate;

  const BappRowCalender(
      {Key key,
      this.holidays,
      this.onDayChanged,
      this.initialDate,
      this.controller})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      headerStyle: HeaderStyle(
          leftChevronIcon: Icon(FeatherIcons.chevronLeft,
              color: Theme.of(context).iconTheme.color),
          rightChevronIcon: Icon(FeatherIcons.chevronLeft,
              color: Theme.of(context).iconTheme.color)),
      initialCalendarFormat: CalendarFormat.week,
      availableCalendarFormats: {CalendarFormat.week: 'Week'},
      calendarController: controller,
      holidays: holidays,
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
