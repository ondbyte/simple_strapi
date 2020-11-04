
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'business_branch_switch.dart';

class BusinessDashboardTab extends StatefulWidget {
  @override
  _BusinessDashboardTabState createState() => _BusinessDashboardTabState();
}

class _BusinessDashboardTabState extends State<BusinessDashboardTab> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            Consumer<CloudStore>(
                              builder: (_, authStore, __) {
                                return Text(
                                    "Hello " + authStore.user.displayName,
                                    style:
                                        Theme.of(context).textTheme.headline1);
                              },
                            ),
                            Text(
                              "Here\'s your business highlights",
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Consumer<BusinessStore>(
                              builder: (_, businessStore, __) {
                                return Observer(
                                  builder: (_) {
                                    return Text(
                                      "For " +
                                          DateFormat("MMMM dd, yyyy").format(
                                              businessStore.dayForTheDetails),
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today_outlined),
                        onPressed: () async {
                          final store = Provider.of<BusinessStore>(context,
                              listen: false);
                          final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: store.dayForTheDetails,
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 365)),
                              lastDate: DateTime.now());
                          store.dayForTheDetails =
                              selectedDate ?? store.dayForTheDetails;
                        },
                      )
                    ],
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
    );
  }
}
