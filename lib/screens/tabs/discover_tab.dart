import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/exceptions.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
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
import 'package:bapp/widgets/hand_picked.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/search_bar.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:bapp/widgets/tiles/complete_your_booking_tile.dart';
import 'package:bapp/widgets/tiles/error.dart';
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
  var getAllCategoriesKey = ValueKey(DateTime.now());
  var nearestFeaturedKey = ValueKey(DateTime.now());

  Widget _getNearestFeatured(BuildContext context) {
    return Builder(
      builder: (_) {
        return TapToReFetch<List<Business>>(
          fetcher: () {
            return BusinessX.i.getNearestBusinesses(
              key: nearestFeaturedKey,
            );
          },
          onTap: () => nearestFeaturedKey = ValueKey(
            DateTime.now(),
          ),
          onErrorBuilder: (_, e, s) {
            bPrint(e);
            bPrint(s);
            return ErrorTile(message: "some error occured, tap to refresh");
          },
          onLoadBuilder: (_) {
            return LoadingWidget();
          },
          onSucessBuilder: (_, businesses) {
            final data = businesses;
            return LayoutBuilder(
              builder: (_, cons) {
                if (data.isNotEmpty) {
                  return SeeAllListTile(
                    padding: EdgeInsets.all(0),
                    seeAllLabel: "See all",
                    title: "Featured Partners",
                    childPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    onSeeAll: () {
                      BappNavigator.push(
                        context,
                        BranchesResultScreen(
                          title: "Featured Partners",
                          branchList: data,
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
                        business: data[i],
                        onTap: () {
                          //Provider.of<BookingFlow>(context, listen: false)
                          //.branch = snap.data[i];
                          BappNavigator.push(
                            context,
                            BusinessProfileScreen(
                              business: data[i],
                            ),
                          );
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
      future: CategoryX.i.getAllCategories(key: getAllCategoriesKey),
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
    final user = UserX.i.user();
    return Builder(
      builder: (_) {
        if (user?.bookings?.isEmpty ?? true) {
          return SizedBox();
        }
        return HowWasYourExperienceTile();
      },
    );
  }

  Widget _getCategoriesScroller(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
      ),
      scrollDirection: Axis.horizontal,
      child: FutureBuilder<List<BusinessCategory>>(
        future: CategoryX.i.getAllCategories(
          key: getAllCategoriesKey,
        ),
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
    return GestureDetector(
      onTap: () {
        final place = UserX.i.userNotPresent
            ? placeName(
                city: DefaultDataX.i.defaultData()?.city,
                locality: DefaultDataX.i.defaultData()?.locality,
              )
            : placeName(
                city: UserX.i.user()?.city,
                locality: UserX.i.user()?.locality,
              );
        if (place is String) {
          BappNavigator.push(
            context,
            BranchesResultScreen(
              placeName: place,
              title: c.name ?? "",
              background: c.image,
              futureBranchList:
                  BusinessX.i.getNearestBusinesses(forCategory: c),
            ),
          );
        } else {
          throw BappException(
            msg:
                "This cannot be the case, unable to get the place name from default data or user data",
          );
        }
      },
      child: RRShape(
        child: Container(
          padding: EdgeInsets.all(10),
          width: 120,
          height: 80,
          decoration: BoxDecoration(
            image: DecorationImage(
              colorFilter: ColorFilter.mode(Colors.black54, BlendMode.multiply),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: () async {
      getAllCategoriesKey = ValueKey(DateTime.now());
    }, child: Builder(
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
                              : Obx(
                                  () => Text(
                                    "Hey, " + (UserX.i.user()?.name ?? ""),
                                  ),
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
                    HandPickedScroller(
                      city: UserX.i.userNotPresent
                          ? DefaultDataX.i.defaultData()?.city
                          : UserX.i.user()?.city,
                      locality: UserX.i.userNotPresent
                          ? DefaultDataX.i.defaultData()?.locality
                          : UserX.i.user()?.locality,
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Top Services on Bapp",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    _getCategoriesScroller(context),
                    if (UserX.i.userPresent)
                      // ignore: dead_code
                      const SizedBox(
                        height: 0,
                      ),
                    if (UserX.i.userPresent)
                      CompleteYourBookingTile(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (UserX.i.userPresent)
                        _getHowWasYourExperience(context),
                      Builder(
                        builder: (
                          _,
                        ) {
                          return (UserX.i.userNotPresent ||
                                  UserX.i.user()?.partner != null)
                              ? const SizedBox() //_getOwnABusiness(context)
                              : const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _getNearestFeatured(context),
                  ],
                ),
              ),
            ],
          );
        });
      },
    ));
  }
}
