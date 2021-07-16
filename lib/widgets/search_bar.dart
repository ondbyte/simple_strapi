import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/search/search_inside_bapp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBarWidget extends StatelessWidget {
  final List<String> possibilities;

  const SearchBarWidget({Key? key, required this.possibilities})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(SearchInsideBappScreen());
      },
      child: Container(
          height: 50,
          width: double.maxFinite,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              possibilities.isNotEmpty
                  ? IgnorePointer(
                      ignoring: true,
                      child: RotateAnimatedTextKit(
                        totalRepeatCount: 4,
                        repeatForever:
                            true, //this will ignore [totalRepeatCount]
                        text: possibilities,
                        textStyle: Theme.of(context).textTheme.subtitle1?.apply(
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.color
                                      ?.withOpacity(0.6),
                                ) ??
                            TextStyle(),
                        pause: const Duration(milliseconds: 500),
                        displayFullTextOnTap: true,
                      ),
                    )
                  : SizedBox(),
              Icon(Icons.search)
            ],
          )),
    );
  }
}
