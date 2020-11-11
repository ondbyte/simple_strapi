import 'package:bapp/config/constants.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/firebase_structures/business_branch.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:bapp/widgets/tabs/business_profile/services_tab.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusinessProfileScreen extends StatefulWidget {
  BusinessProfileScreen();
  @override
  _BusinessProfileScreenState createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<BookingFlow>(context,listen: false);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 256,
            flexibleSpace: FirebaseStorageImage(
              fit: BoxFit.fitHeight,
              storagePathOrURL: flow.branch.images.keys.elementAt(0) ??
                  kTemporaryBusinessImage,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                BusinessTileWidget(
                  branch: flow.branch,
                  onTap: () {},
                  padding: const EdgeInsets.all(16),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                DefaultTabController(
                  length: 4,
                  initialIndex: 2,
                  child: Builder(
                    builder: (_) {
                      return Column(
                        children: [
                          getBappTabBar(context, [
                            const Text("Offers"),
                            const Text("Services"),
                            const Text("Packages"),
                            const Text("About"),
                          ]),
                          const TabBarView(
                            children: [
                             BusinessServicesTab(),
                            ],
                          )
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

PreferredSizeWidget getBappTabBar(BuildContext context, List<Widget> tabs) {
  return TabBar(
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 2,
      ),
    ),
    labelColor: Theme.of(context).primaryColor,
    unselectedLabelColor: Theme.of(context).primaryColorDark,
    indicatorColor: Theme.of(context).primaryColor,
    indicatorPadding: const EdgeInsets.all(16),
    indicatorWeight: 6,
    indicatorSize: TabBarIndicatorSize.tab,
    labelPadding: const EdgeInsets.all(8),
    tabs: tabs,
  );
}
