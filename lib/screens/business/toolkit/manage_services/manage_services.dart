import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/firebase_image.dart';
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
              color: Theme.of(context).indicatorColor,
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
            bottom: getBappTabBar(
              context,
              [
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
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(
                    businessStore.business.selectedBranch.value.businessServices
                        .value.all.length,
                    (index) {
                      final service = businessStore.business.selectedBranch
                          .value.businessServices.value.all[index];
                      return ListTile(
                        title: Text(service.serviceName.value),
                        subtitle: Text(
                          cloudStore.theNumber.country.currency +
                              " " +
                              service.price.value.ceil().toInt().toString() +
                              ", " +
                              service.duration.value.inMinutes.toString() +
                              " Minutes" +
                              "\n" +
                              "Category : " +
                              service.category.value.categoryName.value,
                        ),
                        leading: ListTileFirebaseImage(
                          storagePathOrURL: service.images.isNotEmpty
                              ? service.images.keys.elementAt(0)
                              : service.category.value.images.isNotEmpty
                                  ? service.category.value.images.keys
                                      .elementAt(0)
                                  : kTemporaryPlaceHolderImage,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_forever),
                          onPressed: () async {
                            await businessStore.business.selectedBranch.value
                                .businessServices.value
                                .removeService(service);
                          },
                        ),
                      );
                    },
                  )
                ],
              ),
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
                        businessStore.business.selectedBranch.value
                            .businessServices.value.allCategories.length,
                        (index) {
                          final t = businessStore.business.selectedBranch.value
                              .businessServices.value.allCategories[index];
                          return ListTile(
                            title: Text(t.categoryName.value),
                            subtitle: Text(t.description.value),
                            leading: ListTileFirebaseImage(
                              storagePathOrURL: t.images.isNotEmpty
                                  ? t.images.keys.elementAt(0)
                                  : kTemporaryPlaceHolderImage,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_forever),
                              onPressed: () async {
                                if (businessStore.business.selectedBranch.value
                                    .businessServices.value
                                    .anyServiceDependsOn(t)) {
                                  Flushbar(
                                    message:
                                        "There are some services that depend on this category please remove them first",
                                    duration: const Duration(seconds: 2),
                                  ).show(context);
                                  return;
                                }
                                await businessStore.business.selectedBranch
                                    .value.businessServices.value
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
