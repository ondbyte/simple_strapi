import 'package:bapp/classes/notification_update.dart';
import 'package:bapp/config/config.dart' hide Tab;
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/updates_store.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import 'loading.dart';
import 'login_widget.dart';
import 'store_provider.dart';

class UpdatesTab extends StatefulWidget {
  @override
  _UpdatesTabState createState() => _UpdatesTabState();
}

class _UpdatesTabState extends State<UpdatesTab> {
  int _selectedUpdateTab = 0;
  @override
  Widget build(BuildContext context) {
    return StoreProvider<UpdatesStore>(
      store: Provider.of<UpdatesStore>(context, listen: false),
      builder: (_, updatesStore) {
        return DefaultTabController(
          length: 2,
          child: LayoutBuilder(
            builder: (_, cons) {
              return Observer(
                builder: (_) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 40,
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BubbleTabIndicator(
                            indicatorHeight: 40,
                            tabBarIndicatorSize: TabBarIndicatorSize.tab,
                            indicatorColor: CardsColor.colors["lightGreen"],
                          ),
                          labelStyle: Theme.of(context).textTheme.headline4,
                          labelColor: Theme.of(context).primaryColorLight,
                          unselectedLabelColor:
                              Theme.of(context).primaryColorDark,
                          onTap: (i) {
                            setState(
                              () {
                                _selectedUpdateTab = i;
                              },
                            );
                          },
                          tabs: [
                            Tab(
                              text: "Updates",
                            ),
                            Tab(
                              text: "News",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: cons.maxHeight - 64,
                        child: IndexedStack(
                          index: _selectedUpdateTab,
                          children: [
                            _getUpdates(updatesStore.updates),
                            _getNews(updatesStore.news),
                          ],
                        ),
                      )
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  ///updates tab
  Widget _getUpdates(List<NotificationUpdate> updates) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
            _getTiles(updates),
          ),
        )
      ],
    );
  }

  ///news tab
  Widget _getNews(List<NotificationUpdate> updates) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
            _getTiles(updates),
          ),
        )
      ],
    );
  }

  List<Widget> _getTiles(List<NotificationUpdate> updates) {
    final ws = <Widget>[];
    updates.forEach(
      (element) {
        ws.add(NotificationUpdateTileWidget(
          update: element,
        ));
      },
    );
    return ws;
  }
}

class NotificationUpdateTileWidget extends StatelessWidget {
  final NotificationUpdate update;

  const NotificationUpdateTileWidget({Key key, this.update}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CardsColor.next(),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  update.title,
                  style: Theme.of(context).textTheme.headline2.apply(
                        color: Theme.of(context).primaryColorLight,
                      ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  update.description,
                  style: Theme.of(context).textTheme.bodyText1.apply(
                        color: Theme.of(context).primaryColorLight,
                      ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("I\'m in"),
                IconButton(
                  icon: Icon(FeatherIcons.arrowRightCircle),
                  onPressed: () {},
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
