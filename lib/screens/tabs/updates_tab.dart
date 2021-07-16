import 'package:bapp/classes/firebase_structures/bapp_fcm_message.dart';
import 'package:bapp/config/config.dart' hide Tab;
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';
import 'package:bapp/super_strapi/my_strapi/updateX.dart';
import 'package:bapp/widgets/image/strapi_image.dart';

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
          return DefaultTabController(
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
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
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
                                  text: "What's On",
                                ),
                              ],
                            ),
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
                              _getNews(),
                              _getUpdates(context),
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
  Widget _getUpdates(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder<List<Update>>(
        future: UpdateX.i.getAllCategories(),
        builder: (_, snap) {
          final data = snap.data ?? [];
          return Builder(
            builder: (_) {
              return Column(
                children: [
                  ...List.generate(
                    data.length,
                    (index) => _buildUpdateTile(
                      data[index],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUpdateTile(Update up) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => NewsDetails(update: up)),
          );
        },
        child: Column(
          children: [
            Container(
              // height: 100,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4)),
                    child: Hero(
                        tag: up.id ?? "", child: StrapiImage(file: up.image))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    up.title ?? "",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${up.start?.day.toString()}/${up.start?.month.toString()}/${up.start?.year.toString()} ${up.start?.hour.toString()}:${up.start?.minute.toString()}",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    up.descriptiom ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
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

class NewsDetails extends StatelessWidget {
  final Update update;
  const NewsDetails({Key? key, required this.update}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text("Second Route"),
          ),
      body: Column(
        children: [
          Container(
            // height: 100,
            child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Hero(
                    tag: update.id ?? "",
                    child: StrapiImage(file: update.image))),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.title ?? "",
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "${update.start?.day.toString()}/${update.start?.month.toString()}/${update.start?.year.toString()} ${update.start?.hour.toString()}:${update.start?.minute.toString()}",
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  update.descriptiom ?? "",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
