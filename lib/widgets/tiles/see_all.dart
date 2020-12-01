import 'dart:convert';

import 'package:flutter/material.dart';

class SeeAllListTile extends StatelessWidget {
  final String title, subTitle, seeAllLabel;
  final Function onSeeAll;
  final EdgeInsets padding, titlePadding, childPadding;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const SeeAllListTile({
    Key key,
    this.title = '',
    this.subTitle = '',
    this.seeAllLabel,
    this.onSeeAll,
    this.padding,
    this.itemBuilder,
    this.itemCount,
    this.titlePadding,
    this.childPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, cons) {
        final list = <Widget>[];
        var i = itemCount;
        while (i != 0) {
          i--;
          list.add(
            SizedBox(
              width: cons.maxWidth - (itemCount > 1 ? 32 : 0),
              child: Padding(
                padding: (childPadding ?? EdgeInsets.zero),
                child: itemBuilder(context, i),
              ),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: titlePadding ??
                  const EdgeInsets.only(
                      left: 16, right: 16, top: 10, bottom: 5),
              title: Text(title, style: Theme.of(context).textTheme.headline6),
              trailing: GestureDetector(
                child: Text(
                  seeAllLabel ?? "See all",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onTap: onSeeAll,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: list,
              ),
            ),
          ],
        );
      },
    );
  }
}
