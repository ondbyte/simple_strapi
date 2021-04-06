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
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:bapp/widgets/tiles/viewable_rating_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
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
    var _showReviews = true;
    return Scaffold(
      bottomNavigationBar: Builder(
        builder: (_) {
          return UserX.i.userPresent
              ? BottomPrimaryButton(
                  label: "Book an Appointment",
                  title: null,
                  subTitle: null,
                  onPressed: null,
                )
              : BottomPrimaryButton(
                  label: "Sign in to Book",
                  title: null,
                  subTitle: null,
                  onPressed: null,
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
                                    (e) => e.business?.id == widget.business.id,
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
                                          business: widget.business),
                                    )
                                  : user?.favourites?.removeWhere(
                                      (f) =>
                                          f.business?.name ==
                                          widget.business.name,
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
                  background: Builder(
                    builder: (_) {
                      final img = UserX.i.user()?.partner?.logo?.first.url;
                      if (img is String) {
                        return CachedNetworkImage(imageUrl: img);
                      }
                      return SizedBox();
                    },
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    BusinessTileWidget(
                      titleStyle: Theme.of(context).textTheme.headline1,
                      branch: widget.business,
                      onTap: null,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      onTrailingTapped: () {},
                    ),
                    Builder(builder: (_) {
                      return _showReviews
                          ? getBappTabBar(
                              context,
                              [
                                if (false) const Text("Offers"),
                                const Text("Services"),
                                if (false) const Text("Packages"),
                                const Text("About"),
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
                              ReviewX.i.getReviewsForBusiness(widget.business),
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
                      if (true) const SizedBox(),
                      BusinessProfileServicesTab(
                        business: widget.business,
                      ),
                      if (false) const SizedBox(),
                      BusinessProfileAboutTab(
                        business: widget.business,
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
  }
}
