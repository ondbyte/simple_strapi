import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business_profile/booking_details.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/tiles/customer_booking_tile.dart';
import 'package:bapp/widgets/tiles/see_all.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BusinessDashboardTab extends StatefulWidget {
  @override
  _BusinessDashboardTabState createState() => _BusinessDashboardTabState();
}

class _BusinessDashboardTabState extends State<BusinessDashboardTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<CloudStore, BusinessStore, BookingFlow>(
      builder: (_, cloudStore, businessStore, flow, __) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 16,
                                ),
                                Consumer<CloudStore>(
                                  builder: (_, authStore, __) {
                                    return Text(
                                        "Hello " + authStore.user.displayName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1);
                                  },
                                ),
                                Text(
                                  "Here\'s your business highlights",
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                Consumer<BusinessStore>(
                                  builder: (_, businessStore, __) {
                                    return Observer(
                                      builder: (_) {
                                        return Text(
                                          "For " +
                                              DateFormat("MMMM dd, yyyy")
                                                  .format(businessStore
                                                      .dayForTheDetails),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today_outlined),
                            onPressed: () async {
                              final store = Provider.of<BusinessStore>(context,
                                  listen: false);
                              final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: store.dayForTheDetails,
                                  firstDate: DateTime.now()
                                      .subtract(Duration(days: 365)),
                                  lastDate: DateTime.now());
                              store.dayForTheDetails =
                                  selectedDate ?? store.dayForTheDetails;
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text("Things that need your attention ",
                          style: Theme.of(context).textTheme.subtitle1),
                      Text("Action on below to get your business run smoothly ",
                          style: Theme.of(context).textTheme.bodyText1),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Observer(
                      builder: (_) {
                        if (flow.branchBookings.isEmpty) {
                          return SizedBox();
                        }
                        return BookingsSeeAllTile(
                          title: "New Bookings",
                          bookings: flow.getNewBookings(),
                          titlePadding: EdgeInsets.symmetric(horizontal: 16),
                          childPadding: EdgeInsets.symmetric(horizontal: 8),
                        );
                      },
                    )
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Observer(
                      builder: (_) {
                        if (flow.branchBookings.isEmpty) {
                          return SizedBox();
                        }
                        return BookingsSeeAllTile(
                          title: "Upcoming Bookings",
                          bookings: flow.getUpcomingBookings(),
                          titlePadding: EdgeInsets.symmetric(horizontal: 16),
                          childPadding: EdgeInsets.symmetric(horizontal: 8),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BookingsSeeAllTile extends StatelessWidget {
  final String title;
  final EdgeInsets padding, titlePadding, childPadding;
  final List<BusinessBooking> bookings;

  const BookingsSeeAllTile(
      {Key key,
      this.bookings,
      this.title = "",
      this.padding,
      this.titlePadding,
      this.childPadding})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return SizedBox();
    }
    return SeeAllListTile(
      title: title,
      onSeeAll: () {
        BappNavigator.bappPush(
          context,
          AllBookingsScreen(
            bookings: bookings,
          ),
        );
      },
      itemCount: bookings.length,
      padding: padding,
      titlePadding: titlePadding,
      childPadding: childPadding,
      itemBuilder: (_, i) {
        return BookingTile(
          booking: bookings[i],
          isCustomerView: false,
          onTap: () {
            BappNavigator.bappPush(
              context,
              BookingDetailsScreen(
                booking: bookings[i],
                isCustomerView: false,
              ),
            );
          },
        );
      },
    );
  }
}

class AllBookingsScreen extends StatefulWidget {
  final List<BusinessBooking> bookings;

  const AllBookingsScreen({Key key, this.bookings}) : super(key: key);
  @override
  _AllBookingsScreenState createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends State<AllBookingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All bookings"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemCount: widget.bookings.length,
        itemBuilder: (_, i) {
          return BookingTile(
            booking: widget.bookings[i],
            isCustomerView: false,
            onTap: () {
              BappNavigator.bappPush(
                context,
                BookingDetailsScreen(
                  booking: widget.bookings[i],
                  isCustomerView: false,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
