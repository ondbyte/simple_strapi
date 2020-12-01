import 'package:bapp/classes/firebase_structures/business_category.dart';
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(6)),
              margin: const EdgeInsets.only(bottom: 20),
              child: ListTile(
                title: Text(
                  elements[index].name,
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
