import 'package:bapp/config/constants.dart';
import 'package:bapp/stores/booking_flow.dart';
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
    final flow = Provider.of<BookingFlow>(context, listen: false);
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        initialIndex: 1,
        child: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 256,
                flexibleSpace: FirebaseStorageImage(
                  fit: BoxFit.cover,
                  storagePathOrURL: flow.branch.images.keys.elementAt(0) ??
                      kTemporaryBusinessImage,
                ),
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                BusinessTileWidget(
                  titleStyle: Theme.of(context).textTheme.headline1,
                  branch: flow.branch,
                  onTap: null,
                  padding: EdgeInsets.all(16),
                ),
                SizedBox(
                  height: 20,
                ),
                getBappTabBar(context, [
                  const Text("Offers"),
                  const Text("Services"),
                  const Text("Packages"),
                  const Text("About"),
                ])
              ]))
            ];
          },
          body: TabBarView(
            children: [
              SizedBox(),
              BusinessProfileServicesTab(),
              SizedBox(),
              SizedBox(),
            ],
          ),
        ),
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
    indicatorSize: TabBarIndicatorSize.label,
    labelPadding: const EdgeInsets.all(8),
    tabs: tabs,
  );
}
