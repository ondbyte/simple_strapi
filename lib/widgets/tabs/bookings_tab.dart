import 'package:bapp/classes/firebase_structures/business_timings.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/bapp_calendar.dart';
import 'package:bapp/widgets/login_widget.dart';
import 'package:bapp/widgets/tiles/customer_booking_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingsTab extends StatefulWidget {
  @override
  _BookingsTabState createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  CalendarController _calendarController = CalendarController();

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CloudStore>(
      builder: (_, cloudStore, __) {
        return OrientationBuilder(builder: (_, o) {
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
                        SliverAppBar(
                          elevation: 0,
                          collapsedHeight: 160,
                          expandedHeight: 160,
                          pinned: true,
                          automaticallyImplyLeading: false,
                          actions: [
                            SizedBox(),
                          ],
                          flexibleSpace: BappRowCalender(
                            bookings: flow.myBookingsAsCalendarEvents(),
                            initialDate: DateTime.now(),
                            holidays: flow.holidays,
                            controller: _calendarController,
                            onDayChanged: (day, _, __) {
                              act(() {
                                flow.timeWindow.value =
                                    FromToTiming.forDay(day);
                              });
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
                                  final list = flow.getMyBookingsForDay(
                                      flow.timeWindow.value.from);
                                  if (list.isEmpty) {
                                    return SizedBox();
                                  }
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: list.length,
                                    itemBuilder: (_, i) {
                                      return CustomerBookingTile(
                                        booking: list[i],
                                      );
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    );
            },
          );
        });
      },
    );
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);
}
