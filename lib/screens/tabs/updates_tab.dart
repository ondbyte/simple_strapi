import 'package:bapp/classes/firebase_structures/bapp_fcm_message.dart';
import 'package:bapp/config/config.dart' hide Tab;
import 'package:bapp/stores/updates_store.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class UpdatesTab extends StatefulWidget {
  final Function() keepAlive;

  const UpdatesTab({Key? key, required this.keepAlive}) : super(key: key);
  @override
  _UpdatesTabState createState() => _UpdatesTabState();
}

class _UpdatesTabState extends State<UpdatesTab>
    with AutomaticKeepAliveClientMixin {
  int _selectedUpdateTab = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(
        builder: (
          _,
        ) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: DefaultTabController(
              length: 2,
              child: LayoutBuilder(
                builder: (_, cons) {
                  return Builder(
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
                                indicatorColor:
                                    CardsColor.colors["lightGreen"] ??
                                        Colors.green,
                              ),
                              labelStyle: Theme.of(context).textTheme.headline4,
                              labelColor: Theme.of(context).indicatorColor,
                              unselectedLabelColor:
                                  Theme.of(context).colorScheme.onSurface,
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
                                _getUpdates(),
                                _getNews(),
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
      ),
    );
  }

  ///empty updates
  Widget _getEmpty() {
    return Center(
      child: OrientationBuilder(
        builder: (_, o) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/empty-list.svg",
                width: o == Orientation.landscape ? 100 : 300,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "You are up to date",
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          );
        },
      ),
    );
  }

  ///updates tab
  Widget _getUpdates({List<BappFCMMessage> updates = const []}) {
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
  Widget _getNews({List<BappFCMMessage> updates = const []}) {
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

  List<Widget> _getTiles(List<BappFCMMessage> updates) {
    final ws = <Widget>[];
    updates.forEach(
      (element) {
        ws.add(
          NotificationUpdateTileWidget(
            update: element,
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

  @override
  bool get wantKeepAlive => widget.keepAlive();
}

class NotificationUpdateTileWidget extends StatelessWidget {
  final BappFCMMessage update;

  const NotificationUpdateTileWidget({Key? key, required this.update})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: CardsColor.next(uid: "")
            .withOpacity(/* update.read ? */ false ? 0.4 : 1),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "",
                  style: Theme.of(context).textTheme.headline2?.apply(
                        color: Theme.of(context).indicatorColor,
                      ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "",
                  style: Theme.of(context).textTheme.bodyText1?.apply(
                        color: Theme.of(context).indicatorColor,
                      ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment
                .centerRight, /* 
            child: _decideAndGetButton(context), */
          )
        ],
      ),
    );
  }

  /*  Widget _decideAndGetButton(BuildContext context) {
    Widget? text, button;
    switch (update.type) {
      case MessageOrUpdateType.news:
        {
          text = Text(
            "I'm in",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          );
          button = IconButton(
            icon: Icon(
              FeatherIcons.arrowRightCircle,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {},
          );
          break;
        }
      case MessageOrUpdateType.bookingUpdate:
        {
          text = Text(
            update.read ? "Read" : "Mark as Read",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          );
          button = IconButton(
            icon: Icon(
              update.read ? FeatherIcons.checkCircle : FeatherIcons.circle,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              update.markRead();
            },
          );
          break;
        }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (text != null) text,
        if (button != null) button,
      ],
    );
  }
 */
}
