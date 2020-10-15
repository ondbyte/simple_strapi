import 'package:bapp/config/config.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/widgets/provider/provider_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'business_branch_switch.dart';

class BusinessDashboardTab extends StatefulWidget {
  @override
  _BusinessDashboardTabState createState() => _BusinessDashboardTabState();
}

class _BusinessDashboardTabState extends State<BusinessDashboardTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: BusinessBranchSwitchWidget(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SizedBox(
                      height: 16,
                    ),
                    Consumer<AuthStore>(
                      builder: (_, authStore, __) {
                        return Text("Hello " + authStore.user.displayName,
                            style: Theme.of(context).textTheme.subtitle2);
                      },
                    ),
                    Text("Here\'s your business highlights",
                      style: Theme.of(context).textTheme.headline1,),
                    Text("For",
                      style: Theme.of(context).textTheme.bodyText1,),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Things that need your attention ",
                        style: Theme.of(context).textTheme.subtitle1),
                    Text("Action on below to get your business run smoothly ",
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
