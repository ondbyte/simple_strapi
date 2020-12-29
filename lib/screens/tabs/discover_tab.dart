import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/classes/firebase_structures/business_category.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/business/addbusiness/choose_category.dart';
import 'package:bapp/screens/business/booking_flow/review.dart';
import 'package:bapp/screens/business/business_profile/business_profile.dart';
import 'package:bapp/screens/search/branches_result_screen.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/search_bar.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:bapp/widgets/tiles/see_all_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class DiscoverTab extends StatefulWidget {
  @override
  _DiscoverTabState createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CloudStore>(
      builder: (_, authStore, __) {
        return Observer(builder: (_) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Consumer<CloudStore>(builder: (_, authStore, __) {
                        return authStore.user?.displayName == null
                            ? const SizedBox()
                            : Text("Hey, " + authStore.user.displayName);
                      }),
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
                      if (authStore.status == AuthStatus.userPresent)
                        _getCompleteOrder(context),
                      if (authStore.status == AuthStatus.userPresent)
                        _getHowWasYourExperience(context),
                      const SizedBox(
                        height: 10,
                      ),
                      Consumer<CloudStore>(
                        builder: (_, cloudStore, __) {
                          final businessStore = Provider.of<BusinessStore>(
                              context,
                              listen: false);
                          return (businessStore.business != null)
                              ? const SizedBox()
                              : _getOwnABusiness(context);
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
    return Consumer<CloudStore>(
      builder: (_, cloudStore, __) {
        return FutureBuilder<List<BusinessBranch>>(
          future: cloudStore.getNearestFeatured(),
          builder: (_, snap) {
            return LayoutBuilder(builder: (_, cons) {
              if (snap.hasData && snap.data.isNotEmpty) {
                return SeeAllListTile(
                  title: "Featured on Bapp",
                  childPadding: EdgeInsets.symmetric(horizontal: 16),
                  onSeeAll: () {
                    BappNavigator.push(
                      context,
                      BranchesResultScreen(
                        title: "Featured Service",
                        subTitle: "in " + cloudStore.getAddressLabel(),
                        categoryName: "featured",
                        futureBranchList: Future.value(snap.data),
                        placeName: cloudStore.getAddressLabel(),
                      ),
                    );
                  },
                  itemCount: snap.data.length,
                  itemBuilder: (context, i) {
                    return BusinessTileBigWidget(
                      branch: snap.data[i],
                      onTap: () {
                        Provider.of<BookingFlow>(context, listen: false)
                            .branch = snap.data[i];
                        BappNavigator.push(context, BusinessProfileScreen());
                      },
                      tag: Chip(
                        backgroundColor: CardsColor.colors["lightGreen"],
                        label: Text(
                          "Featured",
                          style: Theme.of(context).textTheme.overline.apply(
                                color: Theme.of(context).primaryColorLight,
                              ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            });
          },
        );
      },
    );
  }

  Widget _getSearchBar() {
    return Consumer<BusinessStore>(
      builder: (_, businessStore, __) {
        businessStore.getCategories();
        return Observer(
          builder: (_) {
            return SearchBarWidget(
              possibilities: Provider.of<BusinessStore>(context, listen: false)
                  .categories
                  .map<String>(
                    (element) => element.name,
                  )
                  .toList(),
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
    return Observer(
      builder: (_) {
        if (flow.myBookings.isEmpty) {
          return SizedBox();
        }
        final bs = flow.getUnratedBookings();
        if (bs.isEmpty) {
          return SizedBox();
        }
        return HowWasYourExperienceTile(
          booking: bs.first,
        );
      },
    );
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);

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
            (e) => Container(
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
                    style: Theme.of(context).textTheme.headline3.apply(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
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
      child: Consumer2<BusinessStore, CloudStore>(
        builder: (_, businessStore, cloudStore, __) {
          return Observer(
            builder: (_) {
              return Row(
                children: [
                  ...List.generate(
                    businessStore.categories.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: _getCategoryBox(
                        businessStore.categories[index],
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

  Widget _getCategoryBox(BusinessCategory category) {
    return RRShape(
      child: Container(
        padding: EdgeInsets.all(10),
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          image: DecorationImage(
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.multiply),
            image: CachedNetworkImageProvider(
              category.image,
            ),
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            category.name,
            style: Theme.of(context).textTheme.bodyText1.apply(
                  color: Theme.of(context).primaryColorLight,
                ),
          ),
        ),
      ),
    );
  }
}
