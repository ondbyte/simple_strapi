import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/booking_flow/see_all_booking.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/padded_text.dart';
import 'package:bapp/widgets/tiles/colored_tile_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:the_country_number/the_country_number.dart';

class BusinessDashboardTab extends StatefulWidget {
  @override
  _BusinessDashboardTabState createState() => _BusinessDashboardTabState();
}

class _BusinessDashboardTabState extends State<BusinessDashboardTab> {
  final _selectedDate = Observable(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Consumer3<CloudStore, BusinessStore, BookingFlow>(
      builder: (_, cloudStore, businessStore, flow, __) {
        return SafeArea(
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
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
                                if (_shouldShowHighlights())
                                  Consumer<BusinessStore>(
                                    builder: (_, businessStore, __) {
                                      return Observer(
                                        builder: (_) {
                                          return Text(
                                            "For " +
                                                DateFormat("MMMM dd, yyyy")
                                                    .format(
                                                  _selectedDate.value,
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
                          if (_shouldShowHighlights())
                            IconButton(
                              icon: const Icon(Icons.calendar_today_outlined),
                              onPressed: () async {
                                final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate.value,
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now());
                                act(() {
                                  _selectedDate.value =
                                      selectedDate ?? _selectedDate.value;
                                });
                              },
                            )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              if (_shouldShowHighlights())
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _getBusinessHighlights(),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    PaddedText(
                      "Things that need your attention ",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    PaddedText(
                      "Action on below to get your business run smoothly ",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
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
                          title: "New Bookings",
                          bookings: flow.getNewBookings(),
                          titlePadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          childPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
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
                          titlePadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          childPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
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

  bool _shouldShowHighlights() {
    final cloudStore = Provider.of<CloudStore>(context, listen: false);
    return (cloudStore.bappUser.userType.value == UserType.businessOwner ||
        cloudStore.bappUser.userType.value == UserType.businessManager ||
        cloudStore.bappUser.userType.value == UserType.businessReceptionist ||
        cloudStore.bappUser.userType.value == UserType.sudo);
  }

  Widget _getBusinessHighlights() {
    return Consumer2<BusinessStore, BookingFlow>(
      builder: (_, businessStore, flow, __) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Observer(
            builder: (_) {
              final bookings = flow.getBookingsForSelectedDay(
                  flow.branchBookings,
                  day: _selectedDate.value);
              final sold = bookings.where((element) =>
                  element.status.value == BusinessBookingStatus.finished);
              final sales = sold
                  .map((e) => e.services.fold(
                      0.0,
                      (previousValue, element) =>
                          previousValue + element.price.value))
                  .toList()
                  .fold(
                      0.0, (previousValue, element) => previousValue + element);
              return Row(
                children: [
                  SizedBox(
                    width: 16,
                  ),
                  ColoredTileBox(
                    title:
                        "Total sales (${TheCountryNumber().parseNumber(internationalNumber: businessStore.business.selectedBranch.value.contactNumber.value).country.currency})",
                    subTitle: "$sales",
                    heightWidth: 160,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ColoredTileBox(
                    title: "Bookings",
                    subTitle: "${bookings.length}",
                    heightWidth: 160,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ColoredTileBox(
                    title: "Ratings",
                    subTitle: "${flow.branch.rating.value}",
                    heightWidth: 160,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
