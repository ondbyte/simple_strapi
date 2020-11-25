import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class BusinessToolkitTab extends StatefulWidget {
  @override
  _BusinessToolkitTabState createState() => _BusinessToolkitTabState();
}

class _BusinessToolkitTabState extends State<BusinessToolkitTab> {
  int _expandedPanel = -1;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: 20, left: 16, right: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _getBranchTile(context),
                  SizedBox(
                    height: 20,
                  ),
                  _getSubmitForVerificationButton(context),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
          _getExpansionTiles(context),
        ],
      ),
    );
  }

  Widget _getExpansionTiles(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            Theme(
              data: Theme.of(context).copyWith(
                  cardColor: Theme.of(context).scaffoldBackgroundColor),
              child: ExpansionPanelList(
                elevation: 0,
                dividerColor: Colors.transparent,
                children: List.generate(
                    BusinessExpandingPanelConfigs.cfgs.length, (i) {
                  return ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: i == _expandedPanel,
                    headerBuilder: (_, expanded) {
                      return ListTile(
                        //tileColor: Theme.of(context).backgroundColor,
                        //selectedTileColor: Theme.of(context).backgroundColor,
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          setState(
                            () {
                              if (_expandedPanel == i) {
                                _expandedPanel = -1;
                              } else {
                                _expandedPanel = i;
                              }
                            },
                          );
                        },
                        title:
                            Text(BusinessExpandingPanelConfigs.cfgs[i].title),
                        subtitle: Text(
                            BusinessExpandingPanelConfigs.cfgs[i].subTitle),
                      );
                    },
                    body: LayoutBuilder(
                      builder: (_, cons) {
                        return Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          height: cons.maxWidth /
                              3 *
                              (BusinessExpandingPanelConfigs
                                          .cfgs[i].tiles.length /
                                      3)
                                  .ceil(),
                          width: cons.maxWidth,
                          child: GridView.count(
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            children: List.generate(
                              BusinessExpandingPanelConfigs
                                  .cfgs[i].tiles.length,
                              (index) => _getTile(
                                context: context,
                                name: BusinessExpandingPanelConfigs
                                    .cfgs[i].tiles[index].name,
                                icon: Icon(BusinessExpandingPanelConfigs
                                    .cfgs[i].tiles[index].iconData),
                                onClick: BusinessExpandingPanelConfigs
                                        .cfgs[i].tiles[index].enabled
                                    ? () {
                                        Navigator.of(context).pushNamed(
                                          BusinessExpandingPanelConfigs.cfgs[i]
                                              .tiles[index].onClickRoute,
                                        );
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                expansionCallback: (i, isExpanded) {},
              ),
            )
          ],
        ),
      ),
    );
  }

  _getTile({
    BuildContext context,
    String name,
    Widget icon,
    Function onClick,
  }) {
    return SizedBox(
      child: FlatButton(
        onPressed: onClick,
        padding: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: CardsColor.colors["purple"].withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              Text(
                name + "\n",
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getBranchTile(BuildContext context) {
    return Consumer<BusinessStore>(
      builder: (_, businessStore, __) {
        return Observer(
          builder: (_) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ListTileFirebaseImage(
                storagePathOrURL: businessStore
                        .business.selectedBranch.value.images.isNotEmpty
                    ? businessStore.business.selectedBranch.value.images.keys
                        .elementAt(0)
                    : kTemporaryPlaceHolderImage,
              ),
              title: Text(
                businessStore.business.selectedBranch.value.name.value,
                maxLines: 1,
              ),
              subtitle: Text(
                businessStore.business.selectedBranch.value.address.value
                    .split("\n")
                    .join(", "),
                maxLines: 1,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border_outlined,
                    color: Colors.yellow[600],
                  ),
                  Text(
                    "4.5",
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  _getSubmitForVerificationButton(BuildContext context) {
    return Consumer<BusinessStore>(
      builder: (_, businessStore, ___) {
        return Observer(
          builder: (_) {
            final draft =
                businessStore.business.selectedBranch.value.status.value ==
                    BusinessBranchActiveStatus.draft;
            final docuVerification =
                businessStore.business.selectedBranch.value.status.value ==
                    BusinessBranchActiveStatus.documentVerification;
            return draft || docuVerification
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: ListTile(
                      tileColor:
                          docuVerification ? Colors.green : Colors.redAccent,
                      title: Text(
                        docuVerification
                            ? "Branch is in verification"
                            : "Submit for verification",
                        style:
                            TextStyle(color: Theme.of(context).indicatorColor),
                      ),
                      trailing: draft
                          ? Icon(
                              FeatherIcons.arrowRightCircle,
                              color: Theme.of(context).indicatorColor,
                            )
                          : null,
                      onTap: docuVerification
                          ? null
                          : () {
                              Navigator.of(context).pushNamed(
                                  RouteManager.businessVerificationScreen);
                            },
                    ),
                  )
                : SizedBox();
          },
        );
      },
    );
  }
}
