import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/booking_flow/booking_details.dart';
import 'package:bapp/widgets/bapp_calendar.dart';
import 'package:bapp/widgets/login_widget.dart';
import 'package:bapp/widgets/tiles/customer_booking_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../classes/firebase_structures/business_timings.dart';
import '../../config/config.dart';
import '../../helpers/helper.dart';
import '../../stores/booking_flow.dart';
import '../../stores/cloud_store.dart';

class BookingsTab extends StatefulWidget {
  @override
  _BookingsTabState createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  final _calendarController = CalendarController();

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CloudStore>(
      builder: (_, cloudStore, __) {
        return OrientationBuilder(
          builder: (_, o) {
            return Observer(
              builder: (_) {
                return cloudStore.status == AuthStatus.anonymousUser
                    ? AskToLoginWidget(
                        loginReason: LoginConfig.bookingTabLoginReason.primary,
                        secondaryReason:
                            LoginConfig.bookingTabLoginReason.secondary,
                      )
                    : o == Orientation.portrait
                        ? CustomScrollView(
                            slivers: <Widget>[
                              _getCalender(),
                              _getBookingsScroll()
                            ],
                          )
                        : _getLandscape();
              },
            );
          },
        );
      },
    );
  }

  Widget _getLandscape() {
    return LayoutBuilder(builder: (_, cons) {
      return Row(
        children: [
          SizedBox(
            height: cons.maxHeight,
            width: cons.maxWidth / 2,
            child: CustomScrollView(
              slivers: [
                _getCalender(),
              ],
            ),
          ),
          SizedBox(
            height: cons.maxHeight,
            width: cons.maxWidth / 2,
            child: CustomScrollView(
              slivers: [
                _getBookingsScroll(),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _getBookingsScroll() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          const SizedBox(
            height: 10,
          ),
          Observer(
            builder: (_) {
              final list = flow.getBookingsForSelectedDay(flow.myBookings);
              if (list.isEmpty) {
                return const SizedBox();
              }
              return ListView.builder(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (_, i) {
                  return BookingTile(
                    onTap: () {
                      BappNavigator.bappPush(
                        context,
                        BookingDetailsScreen(
                          booking: list[i],
                        ),
                      );
                    },
                    booking: list[i],
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }

  double _calenderHeight;
  Widget _getCalender() {
    return SliverAppBar(
      elevation: 0,
      collapsedHeight: 150,
      expandedHeight: 150,
      pinned: true,
      automaticallyImplyLeading: false,
      actions: [
        const SizedBox(),
      ],
      flexibleSpace: BappRowCalender(
        onChildRendered: (s) {
          setState(() {
            _calenderHeight = s.height;
          });
        },
        bookings: flow.myBookingsAsCalendarEvents(),
        initialDate: DateTime.now(),
        holidays: flow.holidays,
        controller: _calendarController,
        onDayChanged: (day, _, __) {
          act(() {
            flow.timeWindow.value = FromToTiming.forDay(day);
          });
        },
      ),
    );
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);
}
