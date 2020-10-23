import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
              tabs: [
                Text("Services"),
                Text("Categories"),
              ],
            ),
          ),
          body: Builder(
            builder: (_) {
              return TabBarView(
                children: [
                  _getServices(context),
                  _getCategories(context),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  Widget _getServices(
    BuildContext context,
  ) {
    return CustomScrollView(
      slivers: [],
    );
  }

  Widget _getCategories(BuildContext context) {
    return Consumer<BusinessStore>(
      builder: (_, businessStore, __) {
        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  ...List.generate(
                    businessStore
                        .business.businessServices.value.allCategories.length,
                    (index) {
                      final t = businessStore
                          .business.businessServices.value.allCategories[index];
                      return ListTile(
                        title: Text(t.categoryName.value),
                        subtitle: Text(t.description.value),
                        leading: t.images.value.isNotEmpty
                            ? FirebaseStorageImage(
                                storagePathOrURL: t.images.value[0],
                              )
                            : SizedBox(),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
