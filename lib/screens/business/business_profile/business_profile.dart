import 'package:bapp/helpers/extensions.dart' show BappNavigator;
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/authentication/login_screen.dart';
import 'package:bapp/screens/business/booking_flow/select_a_professional.dart';
import 'package:bapp/screens/business/booking_flow/select_time_slot.dart';
import 'package:bapp/screens/business/business_profile/tabs/about_tab.dart';
import 'package:bapp/screens/business/business_profile/tabs/services_tab.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:bapp/super_strapi/my_strapi/reviewX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/gallery.dart';
import 'package:bapp/widgets/image/strapi_image.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:bapp/widgets/tiles/viewable_rating_tile.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessProfileScreen extends StatefulWidget {
  final Business business;
  BusinessProfileScreen({required this.business});
  @override
  _BusinessProfileScreenState createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  var _getCartKey = ValueKey(DateTime.now());

  Future _saveScreenData(Booking booking) async {
    if (booking.products?.isEmpty ?? true) {
      return;
    }
    final user = UserX.i.user();
    if (user is User) {
      await Bookings.update(booking);
      final u = await Users.me(asFindOne: true);
      UserX.i.user(u);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenLoading = false.obs;
    return Obx(() {
      if (screenLoading()) {
        return LoadingWidget();
      }
      return SizedBox(
        child: Material(
          child: Businesses.listenerWidget(
            strapiObject: widget.business,
            sync: true,
            builder: (_, business, loading) {
              if (loading) {
                return LoadingWidget();
              }
              var _showReviews = false;
              return TapToReFetch<Booking?>(
                  fetcher: () => BookingX.i
                      .getCart(key: _getCartKey, forBusiness: business),
                  onTap: () => _getCartKey = ValueKey(DateTime.now()),
                  onErrorBuilder: (_, e, s) {
                    bPrint(e);
                    bPrint(s);
                    return ErrorTile(message: "Tap to refresh");
                  },
                  onLoadBuilder: (_) => LoadingWidget(),
                  onSucessBuilder: (_, b) {
                    final booking =
                        Rx<Booking?>(b ?? Booking.fresh(business: business));
                    return WillPopScope(
                      onWillPop: () async {
                        if (booking() is Booking) {
                          screenLoading(true);
                          await _saveScreenData(booking()!);
                        }
                        return true;
                      },
                      child: Scaffold(
                        extendBodyBehindAppBar: true,
                        bottomNavigationBar: Obx(
                          () {
                            var user = UserX.i.user();
                            final products = booking()?.products;
                            if (products is! List ||
                                (products?.isEmpty ?? true)) {
                              return SizedBox();
                            }
                            final title = getNProductsSelectedString(
                              products as List<Product>,
                            );
                            final subTitle =
                                getProductsDurationString(products);
                            if (user is User) {
                              return BottomPrimaryButton(
                                label: "Book an Appointment",
                                title: title,
                                subTitle: subTitle,
                                onPressed: () async {
                                  if (user is! User) {
                                    return;
                                  }
                                  screenLoading(true);
                                  await _saveScreenData(booking()!);
                                  final employee = await BappNavigator.push(
                                    context,
                                    SelectAProfessionalScreen(
                                      business: business,
                                      forDay: DateTime.now(),
                                      title: title,
                                      subTitle: subTitle,
                                    ),
                                  );
                                  if (employee is Employee) {
                                    final timeSlot = await BappNavigator.push(
                                      context,
                                      SelectTimeSlotScreen(
                                        business: widget.business,
                                        employee: employee,
                                        durationOfServices: Duration(
                                            minutes: booking()
                                                    ?.products
                                                    ?.fold<int>(
                                                        0,
                                                        (previousValue,
                                                                element) =>
                                                            previousValue +
                                                            (element.duration ??
                                                                0)) ??
                                                0),
                                      ),
                                    );
                                    if (timeSlot is Timing) {
                                      BappNavigator.pushAndRemoveAll(
                                        context,
                                        ContextualMessageScreen(
                                          buttonText: "Go to bookings",
                                          init: () async {
                                            await BookingX.i.placeBooking(
                                              user: user!,
                                              business: business,
                                              booking: booking()!,
                                              employee: employee,
                                              timeSlot: timeSlot,
                                            );
                                            await BookingX.i.clearCart();
                                          },
                                          onButtonPressed: (context) {
                                            BappNavigator.pushAndRemoveAll(
                                                context,
                                                Bapp(
                                                  goToBookings: true,
                                                ));
                                          },
                                          message:
                                              "Your booking has been placed, waiting to be accepted by the business, track it the bookings tab",
                                        ),
                                      );
                                    }
                                  }

                                  screenLoading(false);
                                },
                              );
                            } else {
                              return BottomPrimaryButton(
                                label: "Sign in to Book",
                                title: title,
                                subTitle: subTitle,
                                onPressed: () async {
                                  await BappNavigator.push(
                                    context,
                                    LoginScreen(),
                                  );
                                  user = UserX.i.user();
                                  if (user is! User) {
                                    return;
                                  }
                                  screenLoading(true);
                                  await _saveScreenData(booking()!);
                                  final employee = await BappNavigator.push(
                                    context,
                                    SelectAProfessionalScreen(
                                      business: business,
                                      forDay: DateTime.now(),
                                      title: title,
                                      subTitle: subTitle,
                                    ),
                                  );
                                  if (employee is Employee) {
                                    final timeSlot = await BappNavigator.push(
                                      context,
                                      SelectTimeSlotScreen(
                                        business: widget.business,
                                        employee: employee,
                                        durationOfServices: Duration(
                                            minutes: booking()
                                                    ?.products
                                                    ?.fold<int>(
                                                        0,
                                                        (previousValue,
                                                                element) =>
                                                            previousValue +
                                                            (element.duration ??
                                                                0)) ??
                                                0),
                                      ),
                                    );
                                    if (timeSlot is Timing) {
                                      BappNavigator.pushAndRemoveAll(
                                        context,
                                        ContextualMessageScreen(
                                          buttonText: "Back to Home",
                                          init: () async {
                                            await BookingX.i.placeBooking(
                                              user: user!,
                                              business: business,
                                              booking: booking()!,
                                              employee: employee,
                                              timeSlot: timeSlot,
                                            );
                                            await BookingX.i.clearCart();
                                          },
                                          onButtonPressed: (context) {
                                            BappNavigator.pushAndRemoveAll(
                                                context, Bapp());
                                          },
                                          message:
                                              "Your booking has been placed, waiting to be accepted by the business, track it the bookings tab",
                                        ),
                                      );
                                    }
                                  }

                                  screenLoading(false);
                                },
                              );
                            }
                          },
                        ),
                        body: DefaultTabController(
                          length: 2 + (true ? 0 : 1) + (true ? 0 : 1),
                          initialIndex: 0,
                          child: NestedScrollView(
                            headerSliverBuilder: (_, __) {
                              return <Widget>[
                                SliverAppBar(
                                  expandedHeight: 256,
                                  actions: [
                                    Builder(
                                      builder: (_) {
                                        return Builder(
                                          builder: (_) {
                                            final hearted = (UserX.i
                                                        .user()
                                                        ?.favourites
                                                        ?.any(
                                                          (e) =>
                                                              e.business?.id ==
                                                              business.id,
                                                        ) ??
                                                    false)
                                                .obs;
                                            return Obx(() {
                                              return IconButton(
                                                icon: Icon(
                                                  hearted()
                                                      ? Icons.favorite
                                                      : Icons
                                                          .favorite_border_outlined,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () async {
                                                  final user = UserX.i.user();
                                                  !hearted()
                                                      ? user is User
                                                          ? user.favourites
                                                              ?.add(
                                                              Favourites(
                                                                addedOn:
                                                                    DateTime
                                                                        .now(),
                                                                business:
                                                                    business,
                                                              ),
                                                            )
                                                          : () async {
                                                              await BappNavigator
                                                                  .push(context,
                                                                      LoginScreen());
                                                              setState(() {});
                                                            }()
                                                      : user?.favourites
                                                          ?.removeWhere(
                                                          (f) =>
                                                              f.business
                                                                  ?.name ==
                                                              business.name,
                                                        );
                                                  hearted(!hearted());
                                                  UserX.i.user(user);
                                                  if (user is User) {
                                                    UserX.i.user(
                                                        await Users.update(
                                                            user));
                                                  }
                                                },
                                              );
                                            });
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        FeatherIcons.share2,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                  flexibleSpace: FlexibleSpaceBar(
                                    background: business.images is List &&
                                            business.images!.isNotEmpty
                                        ? GestureDetector(
                                            onTap: () {
                                              BappNavigator.push(
                                                context,
                                                Gallery(
                                                    images: business.images!),
                                              );
                                            },
                                            child: Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                StrapiImage(
                                                  file: business.images!.first,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: Chip(
                                                      label: Text(
                                                          "${business.images!.length} more images")),
                                                )
                                              ],
                                            ),
                                          )
                                        : StrapiImage(
                                            file: business.partner!.logo!.first,
                                          ),
                                  ),
                                ),
                                SliverList(
                                  delegate: SliverChildListDelegate(
                                    [
                                      BusinessTileWidget(
                                        titleStyle: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                        branch: business,
                                        onTap: null,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        onTrailingTapped: () {},
                                      ),
                                      Builder(builder: (_) {
                                        return !_showReviews
                                            ? getBappTabBar(
                                                context,
                                                [
                                                  const Text("Services"),
                                                  const Text("About"),
                                                  /* if (false) const Text("Offers"),
                                        if (false) const Text("Packages"), */
                                                ],
                                              )
                                            : SizedBox();
                                      })
                                    ],
                                  ),
                                ),
                              ];
                            },
                            body: Stack(
                              children: [
                                Builder(
                                  builder: (_) {
                                    if (_showReviews) {
                                      return Container(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        child: SingleChildScrollView(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          child: FutureBuilder<List<Review>>(
                                            future: ReviewX.i
                                                .getReviewsForBusiness(
                                                    business),
                                            builder: (_, snap) {
                                              if (snap.connectionState ==
                                                  ConnectionState.waiting) {
                                                return LinearProgressIndicator();
                                              }
                                              //flow.ratedBookings.isNotEmpty
                                              final data = snap.data ?? [];
                                              if (_showReviews) {
                                                return Column(
                                                  children: data
                                                      .map(
                                                        (review) =>
                                                            ViewableRating(
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: 16,
                                                            right: 16,
                                                            bottom: 16,
                                                            top: 16,
                                                          ),
                                                          review: review,
                                                        ),
                                                      )
                                                      .toList(),
                                                );
                                              }
                                              return Center(
                                                child: Text("No ratings yet"),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                    return TabBarView(
                                      children: [
                                        BusinessProfileServicesTab(
                                          keepAlive: () => mounted,
                                          business: business,
                                          cart: booking(),
                                          onServicesSelected: (products) {
                                            final copied = booking()?.copyWIth(
                                              products: products,
                                            );
                                            booking(copied);
                                          },
                                        ),
                                        BusinessProfileAboutTab(
                                          business: business,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
      );
    });
  }
}
