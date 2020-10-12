import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class ChooseYourBusinessCategoryScreen extends StatefulWidget {
  @override
  _ChooseYourBusinessCategoryScreenState createState() =>
      _ChooseYourBusinessCategoryScreenState();
}

class _ChooseYourBusinessCategoryScreenState
    extends State<ChooseYourBusinessCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: StoreProvider<BusinessStore>(
          store: Provider.of<BusinessStore>(context, listen: false),
          init: (businessStore) async {
            await businessStore.getCategories();
          },
          builder: (_, businessStore) {
            return Observer(
              builder: (_) {
                return AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOutSine,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Choose your business type",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "People will be able to find your business based on these categories.",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _getCategoriesTiles(
                          context, businessStore.categories.toList())
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _getCategoriesTiles(
      BuildContext context, List<BusinessCategory> categories) {
    return CategoryListTilesWidget(
      elements: categories,
    );
  }
}

class CategoryListTilesWidget extends StatelessWidget {
  final List<BusinessCategory> elements;

  const CategoryListTilesWidget({Key key, this.elements}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            elements.length,
                (index) => Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6)),
              margin: EdgeInsets.only(bottom: 20),
              child: ListTile(
                title: Text(
                  elements[index].normalName,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    RouteManager.thankYouForYourInterestScreen,
                    arguments: elements[index],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
