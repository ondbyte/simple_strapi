import 'package:bapp/classes/firebase_structures/favorite.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart' show BappNavigator;
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/authentication/login_screen.dart';
import 'package:bapp/screens/business/business_profile/select_a_professional.dart';
import 'package:bapp/screens/business/business_profile/tabs/about_tab.dart';
import 'package:bapp/screens/business/business_profile/tabs/services_tab.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';


class BusinessProfileScreen extends StatefulWidget {
  BusinessProfileScreen();
  @override
  _BusinessProfileScreenState createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<BookingFlow>(context, listen: false);
    final cloudStore = Provider.of<CloudStore>(context, listen: false);
    return Scaffold(
      bottomNavigationBar: Observer(
        builder: (_) {
          return cloudStore.status == AuthStatus.userPresent
              ? BottomPrimaryButton(
                  label: "Book an Appointment",
                  title: flow.selectedTitle.value.isNotEmpty
                      ? flow.selectedTitle.value
                      : null,
                  subTitle: flow.selectedSubTitle.value.isNotEmpty
                      ? flow.selectedSubTitle.value
                      : null,
                  onPressed: flow.services.isEmpty
                      ? null
                      : () async {
                          flow.getBranchBookings();
                          await BappNavigator.bappPush(
                              context, const SelectAProfessionalScreen());
                        },
                )
              : BottomPrimaryButton(
                  label: "Sign in to Book",
                  title: flow.selectedTitle.value.isNotEmpty
                      ? flow.selectedTitle.value
                      : null,
                  subTitle: flow.selectedSubTitle.value.isNotEmpty
                      ? flow.selectedSubTitle.value
                      : null,
                  onPressed: flow.services.isEmpty
                      ? null
                      : () async {
                          await BappNavigator.bappPush(context, LoginScreen());
                        },
                );
        },
      ),
      body: DefaultTabController(
        length: 2 +
            (flow.branch.offers.isEmpty ? 0 : 1) +
            (flow.branch.packages.isEmpty ? 0 : 1),
        initialIndex: 0,
        child: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 256,
                actions: [
                  Consumer<CloudStore>(
                    builder: (_, cloudStore, __) {
                      final fav = Favorite(
                          businessBranch: flow.branch,
                          type: FavoriteType.businessBranch);
                      return Observer(
                        builder: (_) {
                          final hearted =
                              cloudStore.favorites.any((e) => e == fav);
                          return IconButton(
                            icon: Icon(
                              hearted
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              cloudStore.addOrRemoveFavorite(fav);
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
                  background: FirebaseStorageImage(
                    fit: BoxFit.cover,
                    storagePathOrURL: flow.branch.images.isNotEmpty
                        ? flow.branch.images.keys.elementAt(0)
                        : kTemporaryPlaceHolderImage,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    BusinessTileWidget(
                      titleStyle: Theme.of(context).textTheme.headline1,
                      branch: flow.branch,
                      onTap: null,
                      padding: EdgeInsets.symmetric(horizontal:16, vertical: 10),
                    ),
                    getBappTabBar(
                      context,
                      [
                        if (flow.branch.offers.isNotEmpty) const Text("Offers"),
                        const Text("Services"),
                        if (flow.branch.packages.isNotEmpty)
                          const Text("Packages"),
                        const Text("About"),
                      ],
                    ),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              if (flow.branch.offers.isNotEmpty) const SizedBox(),
              const BusinessProfileServicesTab(),
              if (flow.branch.packages.isNotEmpty) const SizedBox(),
              const BusinessProfileAboutTab(),
            ],
          ),
        ),
      ),
    );
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context);
}
