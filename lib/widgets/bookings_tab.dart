import 'package:bapp/config/config.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/login_widget.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingsTab extends StatefulWidget {
  @override
  _BookingsTabState createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  Map<DateTime, List<String>> _bookings = {};
  Map<DateTime, List<String>> _holidays = {};
  CalendarController _calendarController = CalendarController();
  DateTime _selectedDay = DateTime.now();

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CloudStore>(
      builder: (_, cloudStore, __) {
        return Observer(
          builder: (_) {
            return cloudStore.status == AuthStatus.anonymousUser
                ? AskToLoginWidget(
                    loginReason: LoginConfig.bookingTabLoginReason.primary,
                    secondaryReason:
                        LoginConfig.bookingTabLoginReason.secondary,
                  )
                : CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate([
                          _buildTableCalendar(),
                        ]),
                      )
                    ],
                  );
          },
        );
      },
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      headerStyle: HeaderStyle(
          leftChevronIcon: Icon(FeatherIcons.chevronLeft,
              color: Theme.of(context).iconTheme.color),
          rightChevronIcon: Icon(FeatherIcons.chevronLeft,
              color: Theme.of(context).iconTheme.color)),
      initialCalendarFormat: CalendarFormat.week,
      availableCalendarFormats: {CalendarFormat.week: 'Week'},
      calendarController: _calendarController,
      events: _bookings,
      holidays: _holidays,
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
      onDaySelected: (
        day,
        events,__
      ) {
        _selectedDay = day;
      },
      onVisibleDaysChanged: (_, __, ___) {},
      onCalendarCreated: (_, __, ___) {
        _calendarController.setSelectedDay(_selectedDay);
      },
    );
  }
}
