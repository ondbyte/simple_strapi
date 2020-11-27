import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_mobx/flutter_mobx.dart';
import "package:provider/provider.dart";

class BranchChooserScreen extends StatelessWidget {
  const BranchChooserScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose your Branch"),
        centerTitle: false,
      ),
      body: Consumer<BusinessStore>(
        builder: (_, businessStore, __) {
          return Observer(
            builder: (context) {
              final branches = businessStore.business.branches.value;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: branches.length,
                  itemBuilder: (_, i) {
                    return BusinessTileWidget(
                        withImage: true,
                        branch: branches[i],
                        onTap: () {
                          act(
                            () {
                              //businessStore.business.branches.value.removeWhere((element) => element.myDoc.value==branches[i].myDoc.value)
                              final neww = branches[i];
                              businessStore.business.selectedBranch.value =
                                  neww;
                            },
                          );
                          Navigator.pop(context);
                        });
                    /*return ListTile(
                    onTap: () {
                      act(
                        () {
                          //businessStore.business.branches.value.removeWhere((element) => element.myDoc.value==branches[i].myDoc.value)
                          final neww = branches[i];
                          businessStore.business.selectedBranch.value = neww;
                        },
                      );
                      Navigator.pop(context);
                    },
                    title: Text(
                      branches[i].name.value,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      branches[i].address.value,
                      maxLines: 3,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                  );*/
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
