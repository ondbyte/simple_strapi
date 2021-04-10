import 'package:bapp/classes/firebase_structures/favorite.dart';
import 'package:bapp/classes/firebase_structures/rating.dart';
import 'package:bapp/helpers/extensions.dart' show BappNavigator;
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/authentication/login_screen.dart';
import 'package:bapp/screens/business/booking_flow/review.dart';
import 'package:bapp/screens/business/booking_flow/select_a_professional.dart';
import 'package:bapp/screens/business/business_profile/tabs/about_tab.dart';
import 'package:bapp/screens/business/business_profile/tabs/services_tab.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/reviewX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:bapp/widgets/image/strapi_image.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:bapp/widgets/tiles/viewable_rating_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessProfileScreen extends StatefulWidget {
  final Business business;
  BusinessProfileScreen({required this.business});
  @override
  _BusinessProfileScreenState createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Businesses.listenerWidget(
        strapiObject: widget.business,
        sync: true,
        builder: (_, business) {
          var _showReviews = false;
          return Scaffold(
            bottomNavigationBar: Obx(
              () {
                final user = UserX.i.user;
                return UserX.i.userPresent
                    ? BottomPrimaryButton(
                        label: "Book an Appointment",
                        title: null,
                        subTitle: null,
                        onPressed: () async {},
                      )
                    : BottomPrimaryButton(
                        label: "Sign in to Book",
                        title: null,
                        subTitle: null,
                        onPressed: () async {
                          BappNavigator.push(
                            context,
                            LoginScreen(),
                          );
                        },
                      );
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
                                final hearted = UserX.i.user()?.favourites?.any(
                                          (e) => e.business?.id == business.id,
                                        ) ??
                                    false;
                                return IconButton(
                                  icon: Icon(
                                    hearted
                                        ? Icons.favorite
                                        : Icons.favorite_border_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final user = UserX.i.user();
                                    !hearted
                                        ? user?.favourites?.add(
                                            Favourites(
                                                addedOn: DateTime.now(),
                                                business: business),
                                          )
                                        : user?.favourites?.removeWhere(
                                            (f) =>
                                                f.business?.name ==
                                                business.name,
                                          );
                                    UserX.i.user(user);
                                    if (user is User) {
                                      UserX.i.user(await Users.update(user));
                                    }
                                  },
                                );
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
                        background: business.partner is Partner
                            ? Partners.listenerWidget(
                                strapiObject: business.partner as Partner,
                                sync: true,
                                builder: (_, partner) {
                                  final files = partner.logo ?? [];
                                  final image =
                                      files.isNotEmpty ? files.first : null;
                                  return StrapiImage(
                                    file: image,
                                  );
                                },
                              )
                            : SizedBox(),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          BusinessTileWidget(
                            titleStyle: Theme.of(context).textTheme.headline1,
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
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: FutureBuilder<List<Review>>(
                                future:
                                    ReviewX.i.getReviewsForBusiness(business),
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
                                            (review) => ViewableRating(
                                              padding: EdgeInsets.only(
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
                              business: business,
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
          );
        });
  }
}
