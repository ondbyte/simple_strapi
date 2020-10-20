import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/firebase_structures/business_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChooseCategoryListTilesWidget extends StatelessWidget {
  final List<BusinessCategory> elements;
  final Function(BusinessCategory) onCategorySelected;

  const ChooseCategoryListTilesWidget(
      {Key key, this.elements, this.onCategorySelected})
      : super(key: key);
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
                  onCategorySelected(elements[index]);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}