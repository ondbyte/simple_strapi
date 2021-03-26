import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/addbusiness/choose_category.dart';
import 'package:bapp/screens/business/booking_flow/review.dart';
import 'package:bapp/screens/business/business_profile/business_profile.dart';
import 'package:bapp/screens/search/branches_result_screen.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/categoryX.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/localityX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_helpers.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:bapp/widgets/search_bar.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:bapp/widgets/tiles/complete_your_booking_tile.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:bapp/widgets/tiles/see_all_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class DiscoverTab extends StatefulWidget {
  @override
  _DiscoverTabState createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (
        _,
      ) {
        return Builder(builder: (_) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Builder(
                        builder: (
                          _,
                        ) {
                          return UserX.i.userNotPresent
                              ? const SizedBox()
                              : Text(
                                  "Hey, " + (UserX.i.user()?.name ?? ""),
                                );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'What can we help you book?',
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _getSearchBar(),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const SizedBox(
                      height: 10,
                    ),
                    _getFeaturedScroller(context),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Top services",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _getCategoriesScroller(context),
                    if (false)
                      // ignore: dead_code
                      const SizedBox(
                        height: 30,
                      ),
                    if (false)
                      CompleteYourBookingTile(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _getNearestFeatured(context),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (UserX.i.userPresent) _getCompleteOrder(context),
                      if (UserX.i.userPresent)
                        _getHowWasYourExperience(context),
                      const SizedBox(
                        height: 10,
                      ),
                      Builder(
                        builder: (
                          _,
                        ) {
                          return (UserX.i.userNotPresent ||
                                  UserX.i.user()?.partner != null)
                              ? _getOwnABusiness(context)
                              : const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _getNearestFeatured(BuildContext context) {
    return Builder(
      builder: (_) {
        return XFutureBuilder<List<Business>>(
          futureCaller: (force) => BusinessX.i.getNearestBusinesses(
            force: force,
          ),
          observe: UserX.i.user,
          builder: (_, snap) {
            final data = snap.data ?? [];
            return LayoutBuilder(
              builder: (_, cons) {
                if (snap.hasData && data.isNotEmpty) {
                  return SeeAllListTile(
                    seeAllLabel: "See all",
                    title: "Featured on Bapp",
                    childPadding: EdgeInsets.symmetric(horizontal: 16),
                    onSeeAll: () {
                      BappNavigator.push(
                        context,
                        BranchesResultScreen(
                          categoryImage: "",
                          title: "Featured Service",
                          subTitle: "in ",
                          categoryName: "featured",
                          futureBranchList: Future.value([...data]),
                          placeName: UserX.i.userNotPresent
                              ? placeName(
                                    city: DefaultDataX.i.defaultData()?.city,
                                    locality:
                                        DefaultDataX.i.defaultData()?.locality,
                                  ) ??
                                  "no place,inform yadu"
                              : placeName(
                                    city: UserX.i.user()?.city,
                                    locality: UserX.i.user()?.locality,
                                  ) ??
                                  "no place,inform yadu",
                        ),
                      );
                    },
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      return BusinessTileBigWidget(
                        branch: data[i],
                        onTap: () {
                          //Provider.of<BookingFlow>(context, listen: false)
                          //.branch = snap.data[i];
                          BappNavigator.push(context,
                              BusinessProfileScreen(business: data[i]));
                        },
                        tag: Chip(
                          backgroundColor: CardsColor.colors["lightGreen"],
                          label: Text(
                            "Featured",
                            style: Theme.of(context).textTheme.overline?.apply(
                                  color: Theme.of(context).primaryColorLight,
                                ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            );
          },
        );
      },
    );
  }

  Widget _getSearchBar() {
    return FutureBuilder<List<BusinessCategory>>(
      future: CategoryX.i.getAllCategories(),
      builder: (_, snap) {
        final data = snap.data ?? [];
        return Builder(
          builder: (_) {
            return SearchBarWidget(
              possibilities: (data.map((e) => e.name ?? "null").toList())
                ..removeWhere((e) => e.isEmpty),
            );
          },
        );
      },
    );
  }

  Widget _getOwnABusiness(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(6)),
      child: ListTile(
        dense: true,
        onTap: () {
          BappNavigator.push(context, ChooseYourBusinessCategoryScreen());
        },
        title: Text("Own a business",
            style: Theme.of(context).textTheme.subtitle1),
        subtitle: Text("List your business on Bapp for free.",
            style: Theme.of(context).textTheme.bodyText2),
        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),
      ),
    );
  }

  Widget _getHowWasYourExperience(BuildContext context) {
    return Builder(
      builder: (_) {
        return SizedBox();
        /* if (flow.myBookings.isEmpty) {
          return SizedBox();
        }
        final bs = flow.getUnratedBookings();
        if (bs.isEmpty) {
          return SizedBox();
        }
        return HowWasYourExperienceTile(
          booking: bs.first,
        ); */
      },
    );
  }

  Widget _getCompleteOrder(BuildContext context) {
    return SizedBox();
  }

  Widget _getFeaturedScroller(context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
          ),
          ...HomeScreenFeaturedConfig.slides.map(
            (e) => GestureDetector(
              child: Container(
                height: 125,
                width: 142,
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: e.cardColor, borderRadius: BorderRadius.circular(6)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      e.icon,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      e.title,
                      style: Theme.of(context).textTheme.headline3?.apply(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                BappNavigator.push(
                  context,
                  BranchesResultScreen(
                    categoryImage: "",
                    categoryName: "",
                    placeName: UserX.i.userNotPresent
                        ? placeName(
                              city: DefaultDataX.i.defaultData()?.city,
                              locality: DefaultDataX.i.defaultData()?.locality,
                            ) ??
                            "no place, inform yadu"
                        : placeName(
                              city: UserX.i.user()?.city,
                              locality: UserX.i.user()?.locality,
                            ) ??
                            "no place, inform yadu",
                    title: e.title.split("\n").join(""),
                    subTitle: "",
                    futureBranchList: Future.value(<Business>[]),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _getCategoriesScroller(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
      ),
      scrollDirection: Axis.horizontal,
      child: FutureBuilder<List<BusinessCategory>>(
        future: CategoryX.i.getAllCategories(),
        builder: (_, snap) {
          final data = snap.data ?? [];
          return Builder(
            builder: (_) {
              return Row(
                children: [
                  ...List.generate(
                    data.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: _getCategoryBox(
                        data[index],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _getCategoryBox(BusinessCategory c) {
    return Obx(() => GestureDetector(
          onTap: () {
            final place = UserX.i.userNotPresent
                ? placeName(
                      city: DefaultDataX.i.defaultData()?.city,
                      locality: DefaultDataX.i.defaultData()?.locality,
                    ) ??
                    "no place, inform yadu"
                : placeName(
                      city: UserX.i.user()?.city,
                      locality: UserX.i.user()?.locality,
                    ) ??
                    "no place, inform yadu";
            BappNavigator.push(
              context,
              BranchesResultScreen(
                categoryImage: c.image?.url ?? "",
                categoryName: c.name ?? "",
                placeName: place,
                title: "Top " + (c.name ?? "no cat name, inform yadu"),
                subTitle: "In " + place,
                futureBranchList: BusinessX.i.getNearestBusinesses(),
              ),
            );
          },
          child: RRShape(
            child: Container(
              padding: EdgeInsets.all(10),
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                image: DecorationImage(
                  colorFilter:
                      ColorFilter.mode(Colors.black54, BlendMode.multiply),
                  image: CachedNetworkImageProvider(
                    c.image?.url,
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  c.name ?? "no cat name, inform yadu",
                  style: Theme.of(context).textTheme.bodyText1?.apply(
                        color: Theme.of(context).primaryColorLight,
                      ),
                ),
              ),
            ),
          ),
        ));
  }
}
