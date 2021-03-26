import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/booking_flow/booking_details.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
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
    return Builder(
      builder: (
        _,
      ) {
        return OrientationBuilder(
          builder: (_, o) {
            return Builder(
              builder: (_) {
                return UserX.i.userPresent
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
                                _getBookingsScroll(),
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

  Widget _getLandscape() {
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
              body: _getBookingsScroll(),
            ),
          ),
        ],
      );
    });
  }

  Widget _getBookingsScroll() {
    return SafeArea(
      child: Builder(
        builder: (_) {
          final list = [];
          if (list.isEmpty) {
            return const SizedBox(
              child: Center(
                child: Text("No bookings"),
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
                onTap: () {
                  BappNavigator.push(
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
        onDayChanged: (day, _, __) {},
      ),
    );
  }
}
