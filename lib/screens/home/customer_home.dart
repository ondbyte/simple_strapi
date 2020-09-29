import 'package:bapp/config/config.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class CustomerHome extends StatefulWidget {
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _selectedPage = 0;
  PageController _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _getPageTitle(_selectedPage),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: IndexedStack(
          children: [
            _getDiscover(context),
            Container(),
            Container(),
            Container(),
          ],
          index: _selectedPage,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 16,
        onTap: (i) {
          setState(() {
            _selectedPage = i;
          });
        },
        currentIndex: _selectedPage,
        items: [
          ...HomeScreenTabsConfig.tabs.map(
            (e) => BottomNavigationBarItem(
              icon: Icon(e.icon),
              title: Text(e.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getDiscover(BuildContext context) {
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
                    height: 10,
                  ),
                  Container(
                    height: 50,
                    width: double.maxFinite,
                    decoration: BoxDecoration(color: Colors.grey[200]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Or Browse Categories"),
                  SizedBox(
                    height: 10,
                  ),
                  _getCategoriesScroller(context),
                  SizedBox(
                    height: 10,
                  ),
                  _getFeaturedScroller(context),
                  if (authStore.status == AuthStatus.userPresent)
                    SizedBox(
                      height: 10,
                    ),
                  if (authStore.status == AuthStatus.userPresent)
                    _getCompleteOrder(context),
                  if (authStore.status == AuthStatus.userPresent)
                    SizedBox(
                      height: 10,
                    ),
                  if (authStore.status == AuthStatus.userPresent)
                    _getHowWasYourExperience(context),
                  if (authStore.status == AuthStatus.anonymous)
                    SizedBox(
                      height: 10,
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
          color: CardsColor.random(), borderRadius: BorderRadius.circular(6)),
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
        trailing: Icon(Icons.arrow_forward_ios),
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
              width: 152,
              margin: EdgeInsets.only(right: 16),
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

  Widget _getPageTitle(int i) {
    switch (i) {
      case 0:
        {
          return Row(
            children: [
              Icon(
                FeatherIcons.mapPin,
                color: Theme.of(context).primaryColorDark,
              ),
              SizedBox(
                width: 10,
              ),
              StoreProvider<CloudStore>(
                store: context.watch<CloudStore>(),
                builder: (_, cloudStore) {
                  return Observer(
                    builder: (_) {
                      return Text(
                        cloudStore.myLocation.locality,
                        style: Theme.of(context).textTheme.headline3,
                      );
                    },
                  );
                },
              ),
            ],
          );
        }
      case 1:
        {
          return Text("Your Bookings");
        }
      case 2:
        {
          return Text("Your Favorites");
        }
      case 3:
        {
          return Text("Updates for you");
        }
      default:
        {
          return SizedBox();
        }
    }
  }
}
