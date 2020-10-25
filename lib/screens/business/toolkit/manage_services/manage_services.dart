import 'package:bapp/config/constants.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class BusinessProductsPricingScreen extends StatefulWidget {
  @override
  _BusinessProductsPricingScreenState createState() =>
      _BusinessProductsPricingScreenState();
}

class _BusinessProductsPricingScreenState
    extends State<BusinessProductsPricingScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(builder: (context) {
        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.add,
              color: Theme.of(context).primaryColorLight,
            ),
            onPressed: () {
              final selected = DefaultTabController.of(context).index;
              if (selected == 0) {
                Navigator.of(context)
                    .pushNamed(RouteManager.businessAddAServiceScreen);
              } else if (selected == 1) {
                Navigator.of(context)
                    .pushNamed(RouteManager.businessAddAServiceCategoryScreen);
              }
            },
          ),
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text("Manage services"),
            bottom: TabBar(
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              labelColor: Theme.of(context).primaryColorDark,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorPadding: EdgeInsets.all(16),
              indicatorWeight: 6,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: EdgeInsets.all(8),
              tabs: [
                Text(
                  "Services",
                  style: Theme.of(context).textTheme.button.apply(
                        color: Theme.of(context).indicatorColor,
                      ),
                ),
                Text(
                  "Categories",
                  style: Theme.of(context).textTheme.button.apply(
                        color: Theme.of(context).indicatorColor,
                      ),
                ),
              ],
            ),
          ),
          body: Builder(
            builder: (_) {
              return TabBarView(
                children: [
                  BusinessServicesTab(
                    keepAlive: () {
                      return mounted;
                    },
                  ),
                  BusinessServiceCategoriesTab(
                    keepAlive: () {
                      return mounted;
                    },
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}

class BusinessServicesTab extends StatefulWidget {
  final Function keepAlive;
  BusinessServicesTab({Key key, @required this.keepAlive}) : super(key: key);

  @override
  _BusinessServicesTabState createState() => _BusinessServicesTabState();
}

class _BusinessServicesTabState extends State<BusinessServicesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer2<BusinessStore, CloudStore>(
      builder: (_, businessStore, cloudStore, __) {
        return Observer(
          builder: (_) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        ...List.generate(
                          businessStore
                              .business.businessServices.value.all.length,
                          (index) {
                            final t = businessStore
                                .business.businessServices.value.all[index];
                            return ListTile(
                              title: Text(t.serviceName.value),
                              subtitle: Text(
                                cloudStore.theNumber.currency +
                                    " " +
                                    t.price.value.ceil().toInt().toString() +
                                    ", " +
                                    t.duration.value.inMinutes.toString() +
                                    " Minutes" +
                                    "\n" +
                                    "Category : " +
                                    t.category.value.categoryName.value,
                              ),
                              leading: FirebaseStorageImage(
                                width: 64,
                                height: 64,
                                storagePathOrURL: t.images.isNotEmpty
                                    ? t.images.keys.elementAt(0)
                                    : t.category.value.images.isNotEmpty
                                        ? t.category.value.images.keys
                                            .elementAt(0)
                                        : kTemporaryBusinessImage,
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_forever),
                                onPressed: () async {
                                  await businessStore
                                      .business.businessServices.value
                                      .removeService(t);
                                },
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive();
}

class BusinessServiceCategoriesTab extends StatefulWidget {
  final Function keepAlive;
  BusinessServiceCategoriesTab({Key key, @required this.keepAlive})
      : super(key: key);

  @override
  _BusinessServiceCategoriesTabState createState() =>
      _BusinessServiceCategoriesTabState();
}

class _BusinessServiceCategoriesTabState
    extends State<BusinessServiceCategoriesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<BusinessStore>(
      builder: (_, businessStore, __) {
        return Observer(builder: (_) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ...List.generate(
                        businessStore.business.businessServices.value
                            .allCategories.length,
                        (index) {
                          final t = businessStore.business.businessServices
                              .value.allCategories[index];
                          return ListTile(
                            title: Text(t.categoryName.value),
                            subtitle: Text(t.description.value),
                            leading: FirebaseStorageImage(
                              width: 64,
                              height: 64,
                              storagePathOrURL: t.images.isNotEmpty
                                  ? t.images.keys.elementAt(0)
                                  : kTemporaryBusinessImage,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_forever),
                              onPressed: () async {
                                if (businessStore
                                    .business.businessServices.value
                                    .anyServiceDependsOn(t)) {
                                  Flushbar(
                                    message:
                                        "There are some services that depend on this category please remove them first",
                                    duration: const Duration(seconds: 2),
                                  ).show(context);
                                  return;
                                }
                                await businessStore
                                    .business.businessServices.value
                                    .removeCategory(t);
                              },
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        });
      },
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive();
}
