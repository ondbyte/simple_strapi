import 'package:bapp/config/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bapp/stores/auth_store.dart';
import 'store_provider.dart';

class DiscoverTab extends StatefulWidget {
  @override
  _DiscoverTabState createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AuthStore>(
      store: context.watch<AuthStore>(),
      builder: (_, authStore) {
        return CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text("Hey User"),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "What can we help you book?",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: double.maxFinite,
                    decoration: BoxDecoration(color: Colors.grey[200]),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Or Browse Categories"),
                  SizedBox(
                    height: 10,
                  ),
                  _getCategoriesScroller(context),
                  SizedBox(
                    height: 20,
                  ),
                  _getFeaturedScroller(context),
                  if (authStore.status == AuthStatus.userPresent)
                    SizedBox(
                      height: 20,
                    ),
                  if (authStore.status == AuthStatus.userPresent)
                    _getCompleteOrder(context),
                  if (authStore.status == AuthStatus.userPresent)
                    SizedBox(
                      height: 20,
                    ),
                  if (authStore.status == AuthStatus.userPresent)
                    _getHowWasYourExperience(context),
                  if (authStore.status == AuthStatus.anonymous)
                    SizedBox(
                      height: 20,
                    ),
                  if (authStore.status == AuthStatus.anonymous)
                    _getOwnABusiness(context),
                ],
              ),
            ),
          ],
        );
      },
    );
  }



  Widget _getOwnABusiness(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: CardsColor.colors[0], borderRadius: BorderRadius.circular(6)),
      child: ListTile(
        title: Text(
          "Own A Business",
          style: Theme.of(context).textTheme.subtitle1.apply(
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        subtitle: Text(
          "List your business on Bapp",
          style: Theme.of(context).textTheme.bodyText1.apply(
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios,color: Theme.of(context).primaryColorLight,),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...HomeScreenFeaturedConfig.slides.map(
                (e) => Container(
              height: 125,
              width: 142,
              margin: EdgeInsets.only(right: 20),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: e.cardColor, borderRadius: BorderRadius.circular(6)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    e.icon,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    e.title,
                    style: Theme.of(context).textTheme.headline3.apply(
                      color: Theme.of(context).primaryColorLight,
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
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FlatButton(
            onPressed: () {},
            child: Text(
              "Mock",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          FlatButton(
            onPressed: () {},
            child: Text(
              "mock two",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          FlatButton(
            onPressed: () {},
            child: Text(
              "Mock 3",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          FlatButton(
            onPressed: () {},
            child: Text(
              "Mock",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          FlatButton(
            onPressed: () {},
            child: Text(
              "Mock",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ),
    );
  }

}
