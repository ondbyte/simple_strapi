import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart' show BappNavigator;
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/business_profile/select_a_professional.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:bapp/widgets/tabs/business_profile/about_tab.dart';
import 'package:bapp/widgets/tabs/business_profile/services_tab.dart';
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
    return Scaffold(
      bottomNavigationBar: Observer(
        builder: (_) {
          return BottomPrimaryButton(
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
          );
        },
      ),
      body: DefaultTabController(
        length: 2 +
            (flow.branch.offers.isEmpty ? 0 : 1) +
            (flow.branch.packages.isEmpty ? 0 : 1),
        initialIndex: 1,
        child: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 256,
                actions: [
                  IconButton(
                    icon: const Icon(
                      FeatherIcons.heart,
                      color: Colors.white,
                    ),
                    onPressed: () {},
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
                      padding: const EdgeInsets.all(16),
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
