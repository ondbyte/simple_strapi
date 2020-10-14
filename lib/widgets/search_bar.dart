import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchBarWidget extends StatelessWidget {
  final List<String> possibilities;

  const SearchBarWidget({Key key, this.possibilities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(RouteManager.searchInsideBapp);
      },
      child: Container(
        height: 50,
        width: double.maxFinite,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark.withOpacity(.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            possibilities.isNotEmpty
                ? RotateAnimatedTextKit(
              totalRepeatCount: 4,
              repeatForever: true, //this will ignore [totalRepeatCount]
              text: possibilities,
              textStyle: Theme.of(context).textTheme.subtitle1.apply(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.6)),
              pause: const Duration(milliseconds: 500),
              displayFullTextOnTap: true,
            )
                : SizedBox(),
            Icon(Icons.search)
          ],
        )
      ),
    );
  }
}
