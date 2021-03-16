import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/classes/firebase_structures/business_category.dart';
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
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:bapp/widgets/search_bar.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:bapp/widgets/tiles/complete_your_booking_tile.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:bapp/widgets/tiles/see_all_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
        return CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Builder(builder: (_) {
                      return UserX.i.userNotPresent
                          ? const SizedBox()
                          : Text("Hey, " + UserX.i.user().name);
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
                  if (CompleteYourBookingTile.shouldShow(context))
                    const SizedBox(
                      height: 30,
                    ),
                  if (CompleteYourBookingTile.shouldShow(context))
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
                    if (UserX.i.userPresent) _getHowWasYourExperience(context),
                    const SizedBox(
                      height: 10,
                    ),
                    Builder(
                      builder: (
                        _,
                      ) {
                        final isAPartner = UserX.i.user().partner == null;
                        return (isAPartner)
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
      },
    );
  }

  Widget _getNearestFeatured(BuildContext context) {
    return SizedBox();
  }

  Widget _getSearchBar() {
    return SizedBox();
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
    return SizedBox();
  }

  Widget _getCompleteOrder(BuildContext context) {
    return SizedBox();
  }

  Widget _getFeaturedScroller(context) {
    return SizedBox();
  }

  Widget _getCategoriesScroller(BuildContext context) {
    return SizedBox();
  }

  Widget _getCategoryBox(BusinessCategory c) {
    return SizedBox();
  }
}
