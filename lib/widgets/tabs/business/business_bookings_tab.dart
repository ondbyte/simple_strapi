import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/booking_flow/services_screen.dart';
import 'package:bapp/screens/business/toolkit/manage_staff/manage_staff.dart';
import 'package:bapp/screens/business_profile/select_a_professional.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../bapp_calendar.dart';
import '../../booking_timeline.dart';

class BusinessBookingsTab extends StatefulWidget {
  @override
  _BusinessBookingsTabState createState() => _BusinessBookingsTabState();
}

class _BusinessBookingsTabState extends State<BusinessBookingsTab> {
  CalendarController _calendarController = CalendarController();
  final _selectedDay = Observable(DateTime.now());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      flow.branch =
          Provider.of<BusinessStore>(context).business.selectedBranch.value;
    });
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Observer(builder: (_) {
        return flow.professional.value == null
            ? SizedBox()
            : FloatingActionButton(
                onPressed: () {
                  BappNavigator.bappPush(
                      context, BusinessProfileServicesScreen());
                },
                child: Icon(FeatherIcons.plus),
              );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            expandedHeight: 240,
            collapsedHeight: 240,
            actions: [SizedBox()],
            flexibleSpace: Observer(
              builder: (_) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (flow.professional.value != null)
                      BusinessStaffListTile(
                        staff: flow.professional.value.staff,
                        trailing: IconButton(
                          icon: Icon(FeatherIcons.refreshCcw),
                          onPressed: () {
                            flow.getBranchBookings();
                            BappNavigator.bappPush(
                              context,
                              SelectAProfessionalScreen(
                                onSelected: (proffesional) {
                                  act(() {
                                    flow.professional.value = proffesional;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    if (flow.professional.value == null)
                      ListTile(
                        onTap: () {
                          flow.getBranchBookings();
                          BappNavigator.bappPush(
                            context,
                            SelectAProfessionalScreen(
                              onSelected: (proffesional) {
                                act(() {
                                  flow.professional.value = proffesional;
                                });
                              },
                            ),
                          );
                        },
                        title: Text("Staff"),
                        subtitle: Text("Select a staff"),
                        trailing: Icon(FeatherIcons.arrowRight),
                      ),
                    BappRowCalender(
                      bookings: flow.myBookingsAsCalendarEvents(),
                      initialDate: DateTime.now(),
                      holidays: flow.holidays,
                      controller: _calendarController,
                      onDayChanged: (day, _, __) {
                        act(() {
                          _selectedDay.value = day;
                        });
                      },
                    )
                  ],
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 20,
                ),
                Observer(
                  builder: (_) {
                    return flow.professional.value == null
                        ? SizedBox()
                        : BookingTimeLineWidget(
                            date: _selectedDay.value,
                            list:
                                flow.getStaffBookingsForDay(_selectedDay.value),
                          );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);
}
