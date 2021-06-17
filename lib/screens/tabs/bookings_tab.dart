import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/booking_flow/booking_details.dart';
import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/bapp_calendar.dart';
import 'package:bapp/widgets/login_widget.dart';
import 'package:bapp/widgets/tiles/customer_booking_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';
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
    return Obx(
      () {
        final user = UserX.i.user();
        return OrientationBuilder(
          builder: (_, o) {
            return Builder(
              builder: (_) {
                return UserX.i.userNotPresent
                    ? AskToLoginWidget(
                        loginReason: LoginConfig.bookingTabLoginReason.primary,
                        secondaryReason:
                            LoginConfig.bookingTabLoginReason.secondary,
                      )
                    : CustomScrollView(
                        slivers: <Widget>[
                          _getCalender(),
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                _getBookingsScroll(UserX.i.user()!),
                              ],
                            ),
                          )
                        ],
                      );
              },
            );
          },
        );
      },
    );
  }

  Widget _getLandscape(User user) {
    return LayoutBuilder(builder: (_, cons) {
      return Row(
        children: [
          SizedBox(
            height: cons.maxHeight,
            width: cons.maxWidth / 2,
            child: NestedScrollView(
              headerSliverBuilder: (_, __) {
                return [_getCalender()];
              },
              body: _getBookingsScroll(user),
            ),
          ),
        ],
      );
    });
  }

  Widget _getBookingsScroll(User user) {
    return SafeArea(
      child: Builder(
        builder: (
          _,
        ) {
          final list = getBookingsForDay(
              user.bookings ?? [], _calendarController.selectedDay);
          if (list.isEmpty) {
            return const SizedBox(
              child: Center(
                child: Text(
                  "No bookings",
                ),
              ),
            );
          }
          return ListView.builder(
            key: UniqueKey(),
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (_, i) {
              return BookingTile(
                onTap: (booking) {
                  BappNavigator.push(
                    context,
                    BookingDetailsScreen(
                      booking: booking,
                    ),
                  );
                },
                booking: list[i],
              );
            },
          );
        },
      ),
    );
  }

  double? _calenderHeight;
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
            _calenderHeight = (s?.height);
          });
        },
        initialDate: DateTime.now(),
        controller: _calendarController,
        onDayChanged: (day, _, __) {
          setState(() {
            _calendarController.setSelectedDay(day);
          });
        },
      ),
    );
  }
}
