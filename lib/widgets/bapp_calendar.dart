import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class BappRowCalender extends StatefulWidget {
  final Map<DateTime, List> holidays;
  final Map<DateTime, List> bookings;
  final Function(DateTime, List, List) onDayChanged;
  final CalendarController controller;
  final DateTime initialDate;
  final Function(Size) onChildRendered;

  const BappRowCalender({Key key, this.holidays, this.bookings, this.onDayChanged, this.controller, this.initialDate, this.onChildRendered}) : super(key: key);
  @override
  _BappRowCalenderState createState() => _BappRowCalenderState();
}

class _BappRowCalenderState extends State<BappRowCalender> {
  final _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
    
      key: _key,


      headerStyle: HeaderStyle(
        
            leftChevronIcon: Icon(FeatherIcons.arrowLeftCircle,
                color: Theme.of(context).iconTheme.color),
            rightChevronIcon: Icon(FeatherIcons.arrowRightCircle,
                color: Theme.of(context).iconTheme.color)),
        initialCalendarFormat: CalendarFormat.week,
        availableCalendarFormats: {CalendarFormat.week: 'Week'},
        calendarController: widget.controller,
        events: widget.bookings,
        holidays: widget.holidays,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          
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
        widget.controller.setSelectedDay(day);
        widget.onDayChanged(day, events, __);
      },
      onVisibleDaysChanged: (_, __, ___) {},
      onCalendarCreated: (_, __, ___) {
        widget.controller.setSelectedDay(widget.initialDate);
        if(widget.onChildRendered!=null){
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            widget.onChildRendered(context.size);
          });
        }
      },
    );
  }
}

