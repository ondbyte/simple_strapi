import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/search/branches_result_screen.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/categoryX.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/choose_category.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class SearchInsideBappScreen extends StatefulWidget {
  @override
  _SearchInsideBappScreenState createState() => _SearchInsideBappScreenState();
}

class _SearchInsideBappScreenState extends State<SearchInsideBappScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text("Search on Bapp"),
      ),
      body: Builder(
        builder: (
          _,
        ) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (_) {
                return TapToReFetch<List<BusinessCategory>>(
                    fetcher: () =>
                        CategoryX.i.getAllCategories(key: ValueKey(hashCode)),
                    onLoadBuilder: (_) => LoadingWidget(),
                    onErrorBuilder: (_, e, s) {
                      bPrint(e);
                      bPrint(s);
                      return ErrorTile(
                        message: "Something went wrong, tap to retry",
                      );
                    },
                    onSucessBuilder: (context, list) {
                      return ChooseCategoryListTilesWidget(
                        elements: list,
                        onCategorySelected: (c) {
                          final pn = UserX.i.userNotPresent
                              ? placeName(
                                    city: DefaultDataX.i.defaultData()?.city,
                                    locality:
                                        DefaultDataX.i.defaultData()?.locality,
                                  ) ??
                                  "no place,inform yadu"
                              : placeName(
                                    city: UserX.i.user()?.city,
                                    locality: UserX.i.user()?.locality,
                                  ) ??
                                  "no place,inform yadu";
                          Get.to(
                            BranchesResultScreen(
                              placeName: pn,
                              title: c.name ?? "",
                              futureBranchList:
                                  BusinessX.i.getNearestBusinesses(
                                key: ValueKey(
                                  hashCode,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    });
              },
            ),
          );
        },
      ),
    );
  }
}
