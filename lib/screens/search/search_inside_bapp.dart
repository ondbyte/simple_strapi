import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/search/branches_result_screen.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:bapp/widgets/choose_category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                return ChooseCategoryListTilesWidget(
                  elements: [],
                  onCategorySelected: (c) {
                    final pn = UserX.i.userNotPresent
                        ? placeName(
                              city: DefaultDataX.i.defaultData()?.city,
                              locality: DefaultDataX.i.defaultData()?.locality,
                            ) ??
                            "no place,inform yadu"
                        : placeName(
                              city: UserX.i.user()?.city,
                              locality: UserX.i.user()?.locality,
                            ) ??
                            "no place,inform yadu";
                    BappNavigator.push(
                      context,
                      BranchesResultScreen(
                        categoryImage: "",
                        categoryName: c.name ?? "",
                        placeName: pn,
                        title: "Top " + (c.name ?? ""),
                        subTitle: "In " + pn,
                        futureBranchList: BusinessX.i.getNearestBusinesses(),
                      ),
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
}
