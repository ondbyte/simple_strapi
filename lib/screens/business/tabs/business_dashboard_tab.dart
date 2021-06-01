import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/booking_flow/booking_details.dart';
import 'package:bapp/screens/business/booking_flow/see_all_booking.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:bapp/super_strapi/my_strapi/persistenceX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/padded_text.dart';
import 'package:bapp/widgets/tiles/colored_tile_box.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';
import 'package:the_country_number/the_country_number.dart';

class BusinessDashboardTab extends StatefulWidget {
  @override
  _BusinessDashboardTabState createState() => _BusinessDashboardTabState();
}

class _BusinessDashboardTabState extends State<BusinessDashboardTab> {
  final _selectedDate = Observable(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final user = UserX.i.user()!;
    return Users.listenerWidget(
      strapiObject: user,
      builder: (_, user, userLoading) {
        return Partners.listenerWidget(
            strapiObject: user.partner!,
            sync: true,
            builder: (context, partner, partnerLoading) {
              if (partner.businesses?.isEmpty ?? true) {
                return Text("no businesses");
              }
              return Obx(() {
                final pickedBusiness = user.pickedBusiness;
                if (pickedBusiness is! Business) {
                  return Text("No business selected");
                }
                return Businesses.listenerWidget(
                    strapiObject: pickedBusiness,
                    builder: (context, selectedBusiness, loading) {
                      return SafeArea(
                        child: CustomScrollView(
                          shrinkWrap: true,
                          slivers: [
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              Builder(
                                                builder: (
                                                  _,
                                                ) {
                                                  return Text(
                                                    "Hello " + user.name!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline1,
                                                  );
                                                },
                                              ),
                                              Text(
                                                "Here\'s your business highlights",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1,
                                              ),
                                              if (_shouldShowHighlights())
                                                Builder(
                                                  builder: (
                                                    _,
                                                  ) {
                                                    return Observer(
                                                      builder: (_) {
                                                        return Text(
                                                          "For " +
                                                              DateFormat(
                                                                      "MMMM dd, yyyy")
                                                                  .format(
                                                                _selectedDate
                                                                    .value,
                                                              ),
                                                          style:
                                                              Theme.of(context)
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
                                            icon: const Icon(
                                                Icons.calendar_today_outlined),
                                            onPressed: () async {
                                              final selectedDate =
                                                  await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          _selectedDate.value,
                                                      firstDate: DateTime.now()
                                                          .subtract(
                                                              const Duration(
                                                                  days: 365)),
                                                      lastDate: DateTime.now());
                                              act(() {
                                                _selectedDate.value =
                                                    selectedDate ??
                                                        _selectedDate.value;
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
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                  PaddedText(
                                    "Action on below to get your business run smoothly ",
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ],
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  TapToReFetch<List<Booking>>(
                                    fetcher: () => BookingX.i
                                        .getUpcomingBookingsToBeAccepted(
                                            selectedBusiness),
                                    onLoadBuilder: (_) => LoadingWidget(),
                                    onErrorBuilder: (_, e, s) {
                                      return ErrorTile(message: "$e");
                                    },
                                    onSucessBuilder: (_, bookings) {
                                      return BookingsSeeAllTile(
                                        title: "New Bookings",
                                        bookings: bookings,
                                        titlePadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        childPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        onSelected: (booking) async {
                                          await BappNavigator.push(
                                            context,
                                            BookingDetailsScreen(
                                              booking: booking,
                                              isCustomerView: false,
                                            ),
                                          );
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  TapToReFetch<List<Booking>>(
                                    fetcher: () => BookingX.i
                                        .getUpcomingBookings(selectedBusiness),
                                    onLoadBuilder: (_) => LoadingWidget(),
                                    onErrorBuilder: (_, e, s) {
                                      return ErrorTile(message: "$e");
                                    },
                                    onSucessBuilder: (_, bookings) {
                                      return BookingsSeeAllTile(
                                        title: "Upcoming Bookings",
                                        bookings: bookings,
                                        titlePadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                        childPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        onSelected: (booking) async {
                                          await BappNavigator.push(
                                            context,
                                            BookingDetailsScreen(
                                              booking: booking,
                                              isCustomerView: false,
                                            ),
                                          );
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              });
            });
      },
    );
  }

  bool _shouldShowHighlights() {
    return false;
  }

  Widget _getBusinessHighlights() {
    return SizedBox();
    /* return Consumer2<BusinessStore, BookingFlow>(
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
   */
  }
}
