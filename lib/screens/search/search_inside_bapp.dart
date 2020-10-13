import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';

import 'package:bapp/widgets/choose_category.dart';
import 'package:bapp/widgets/store_provider.dart';
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
      body: StoreProvider<BusinessStore>(
        store: Provider.of<BusinessStore>(context),
        builder: (_, businessStore) {
          return ChooseCategoryListTilesWidget(
            elements: businessStore.categories,
            onCategorySelected: (c){
              Navigator.of(context).pushNamed(RouteManager.showResultsScreen,arguments: c);
            },
          );
        },
      ),
    );
  }
}
