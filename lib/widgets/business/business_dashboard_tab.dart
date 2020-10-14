import 'package:bapp/config/config.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/widgets/provider/provider_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusinessDashboardTab extends StatefulWidget {
  @override
  _BusinessDashboardTabState createState() => _BusinessDashboardTabState();
}

class _BusinessDashboardTabState extends State<BusinessDashboardTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Text("Your business highlights",
                        style: Theme.of(context).textTheme.headline1),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: ListTile(
                        title: Text("AL HANA",
                            style: Theme.of(context).textTheme.subtitle1.apply(
                                color: Theme.of(context).primaryColorLight)),
                        trailing: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(.2),
                            borderRadius: BorderRadius.circular(6)),
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 120,
                          child: Text("place holder"),
                        )),
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
