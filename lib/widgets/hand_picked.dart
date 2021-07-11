import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/search/branches_result_screen.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/handPickedX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class HandPickedScroller extends StatefulWidget {
  HandPickedScroller({
    Key? key,
  }) : super(key: key);

  @override
  _HandPickedScrollerState createState() => _HandPickedScrollerState();
}

class _HandPickedScrollerState extends State<HandPickedScroller> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final city = UserX.i.userNotPresent
          ? DefaultDataX.i.defaultData()?.city
          : UserX.i.user()?.city;
      final locality = UserX.i.userNotPresent
          ? DefaultDataX.i.defaultData()?.locality
          : UserX.i.user()?.locality;
      return TapToReFetch<List<HandPicked>>(
        fetcher: () => HandPickedX.i.getAll(
          city,
          locality,
        ),
        onLoadBuilder: (_) => LoadingWidget(),
        onErrorBuilder: (_, e, s) {
          bPrint(e);
          bPrint(s);
          return SizedBox();
<<<<<<< HEAD
          return ErrorTile(message: "Something wentwrong, please tap to retry");
        },
        onSucessBuilder: (context, list) {
          if (list.isEmpty) {
            return SizedBox();
          }
          return SizedBox(
            height: MediaQuery.of(context).size.height * .15,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  // crossAxisSpacing: 5,
                  mainAxisSpacing: 15),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemBuilder: (_, i) {
                return HandPickedBox(
                  handPicked: list[i],
                  onPicked: () {
                    BappNavigator.push(
                      context,
                      BranchesResultScreen(
                        branchList: list[i].businesses,
                        title: list[i].name ?? "",
                        placeName:
                            DefaultDataX.i.defaultData()?.locality?.name ??
                                DefaultDataX.i.defaultData()?.city?.name ??
                                "",
                      ),
                    );
                  },
                );
              },
=======
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height * .15,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                // crossAxisSpacing: 5,
                mainAxisSpacing: 15),
            // shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
>>>>>>> 461852e313f3144dfccc46c779bb77679aebc727
            ),
          );
        },
      );
    });
  }
}

class HandPickedBox extends StatelessWidget {
  final HandPicked handPicked;
  final Function() onPicked;
  const HandPickedBox(
      {Key? key, required this.handPicked, required this.onPicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPicked,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        child: Container(
          height: 125,
          width: 142,
          // margin: const EdgeInsets.only(right: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CardsColor.next(),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon(
              // FeatherIcons.package,
              // color: Colors.white,
              // ),
              const SizedBox(
                height: 6,
              ),
              Text(
                handPicked.name ?? "",
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.apply(color: Theme.of(context).primaryColorLight),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
