import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/business/business_branch_switch.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class BusinessToolkitTab extends StatefulWidget {
  @override
  _BusinessToolkitTabState createState() => _BusinessToolkitTabState();
}

class _BusinessToolkitTabState extends State<BusinessToolkitTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: BusinessBranchSwitchWidget(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _getBranchTile(context),
                    SizedBox(
                      height: 20,
                    ),
                    _getSubmitForVerificationButton(context),

                    ///TO DO implementupdates bar
                    SizedBox(
                      height: 20,
                    ),
                    ExpansionPanelList(
                      children: [
                        ExpansionPanel(headerBuilder: (_,), body: null)
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
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
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl:
                      businessStore.business.selectedBranch.value.images[0],
                  height: 80,
                  width: 80,
                ),
              ),
              title: Text(
                businessStore.business.selectedBranch.value.name,
                maxLines: 1,
              ),
              subtitle: Text(
                businessStore.business.selectedBranch.value.address
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        title: Text(
          "Submit for verification",
          style: TextStyle(color: Theme.of(context).primaryColorLight),
        ),
        trailing: Icon(FeatherIcons.arrowRightCircle,
            color: Theme.of(context).primaryColorLight),
      ),
    );
  }

  _getGrowYourBusinessCollapserWidget(BuildContext context) {
    return ExpandablePanel(
      header: Text("Grow your Business"),
      collapsed: Text(
        "Set of tools to help you grow your business",
        softWrap: true,
        maxLines: 1,
      ),
      expanded: LayoutBuilder(
        builder: (_, cons) {
          return GridView.count(
            crossAxisCount: 3,
            children: [
              Container(
                width: cons.maxWidth / 3,
                color: Colors.red,
                child: Text("YAAA"),
              ),
              Container(
                width: cons.maxWidth / 3,
                color: Colors.red,
                child: Text("YAAA"),
              ),
              Container(
                width: cons.maxWidth / 3,
                color: Colors.red,
                child: Text("YAAA"),
              ),
            ],
          );
        },
      ),
    );
    return ExpansionTile(
      title: Text("Grow your Business"),
      subtitle: Text("Set of tools to help you grow your business"),
      children: [
        GridView.count(
          crossAxisCount: 3,
          children: [
            Container(
              child: Text("YAAA"),
            ),
            Container(
              child: Text("YAAA"),
            ),
            Container(
              child: Text("YAAA"),
            ),
          ],
        )
      ],
    );
  }
}
