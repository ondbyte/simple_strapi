import 'dart:math';

import 'package:bapp/classes/feedback.dart';
import 'package:bapp/classes/notification_update.dart';
import 'package:bapp/config/config.dart' hide Tab;
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/updates_store.dart';
import 'package:bapp/widgets/undo_widget.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
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
        return Padding(
          padding: EdgeInsets.all(16),
          child: DefaultTabController(
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
                            labelColor: Theme.of(context).indicatorColor,
                            unselectedLabelColor:
                                Theme.of(context).indicatorColor,
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
                          height: 20,
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
          ),
        );
      },
    );
  }

  ///empty updates
  Widget _getEmpty() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/svg/empty-list.svg",
            width: 300,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "You are up to date",
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ],
      ),
    );
  }

  ///updates tab
  Widget _getUpdates(Map<String, NotificationUpdate> updates) {
    return updates.isNotEmpty
        ? CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                  _getTiles(updates),
                ),
              )
            ],
          )
        : _getEmpty();
  }

  ///news tab
  Widget _getNews(Map<String, NotificationUpdate> updates) {
    return updates.isNotEmpty
        ? CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                  _getTiles(updates),
                ),
              )
            ],
          )
        : _getEmpty();
  }

  List<Widget> _getTiles(Map<String, NotificationUpdate> updates) {
    final ws = <Widget>[];
    updates.forEach(
      (id, element) {
        ws.add(
          Dismissible(
            key: Key(id),
            onDismissed: (d) {
              Provider.of<UpdatesStore>(context, listen: false).remove(element);
              Provider.of<UpdatesStore>(context, listen: false)
                  .setViewedForUpdate(element);
            },
            child: NotificationUpdateTileWidget(
              update: element,
            ),
          ),
        );
        ws.add(
          SizedBox(
            height: 20,
          ),
        );
      },
    );
    if (ws.isNotEmpty) ws.removeLast();
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
        color: update.myColor,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.title,
                  style: Theme.of(context).textTheme.headline2.apply(
                        color: Theme.of(context).indicatorColor,
                      ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  update.description,
                  style: Theme.of(context).textTheme.bodyText1.apply(
                        color: Theme.of(context).indicatorColor,
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
                Text(
                  "I\'m in",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .apply(color: Theme.of(context).indicatorColor),
                ),
                IconButton(
                  icon: Icon(
                    FeatherIcons.arrowRightCircle,
                    color: Theme.of(context).indicatorColor,
                  ),
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
