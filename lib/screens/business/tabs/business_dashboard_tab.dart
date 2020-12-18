import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/booking_flow/booking_details.dart';
import 'package:bapp/screens/business/booking_flow/see_all_booking.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/tiles/customer_booking_tile.dart';
import 'package:bapp/widgets/tiles/see_all_tile.dart';
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                      style:
                                          Theme.of(context).textTheme.headline1,
                                    );
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
                                                  .format(
                                                businessStore.dayForTheDetails,
                                              ),
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
                            icon: const Icon(Icons.calendar_today_outlined),
                            onPressed: () async {
                              final store = Provider.of<BusinessStore>(context,
                                  listen: false);
                              final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: store.dayForTheDetails,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now());
                              store.dayForTheDetails =
                                  selectedDate ?? store.dayForTheDetails;
                            },
                          )
                        ],
                      ),
                      const SizedBox(
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
                          return const SizedBox();
                        }
                        return BookingsSeeAllTile(
                          title: "New Bookings",
                          bookings: flow.getNewBookings(),
                          titlePadding: const EdgeInsets.symmetric(horizontal: 16),
                          childPadding: const EdgeInsets.symmetric(horizontal: 8),
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
                          return const SizedBox();
                        }
                        return BookingsSeeAllTile(
                          title: "Upcoming Bookings",
                          bookings: flow.getUpcomingBookings(),
                          titlePadding: const EdgeInsets.symmetric(horizontal: 16),
                          childPadding: const EdgeInsets.symmetric(horizontal: 8),
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
