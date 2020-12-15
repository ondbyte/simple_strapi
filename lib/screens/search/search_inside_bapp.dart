import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/search/branches_result_screen.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
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
      body: Consumer<BusinessStore>(
        builder: (_, businessStore,__) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<CloudStore>(
              builder: (_, cloudStore, __) {
                return ChooseCategoryListTilesWidget(
                  elements: businessStore.categories,
                  onCategorySelected: (c) {
                    BappNavigator.push(
                      context,
                      BranchesResultScreen(
                        categoryName: c.name,
                        placeName: cloudStore.getAddressLabel(),
                        title: "Top " + c.name,
                        subTitle: "In " + cloudStore.getAddressLabel(),
                        futureBranchList: cloudStore.getBranchesForCategory(
                          c,
                        ),
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
