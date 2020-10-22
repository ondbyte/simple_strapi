import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/business_store.dart';
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
              return ListView.builder(
                shrinkWrap: true,
                itemCount: branches.length,
                itemBuilder: (_, i) {
                  return ListTile(
                    onTap: () {
                      act(
                        () {
                          final neww = branches[i];
                          final old = businessStore.business.selectedBranch.value;
                          if(neww.myDoc==old.myDoc){
                            return;
                          }
                          branches.removeWhere((b) => b.myDoc==old.myDoc);
                          businessStore.business.branches.value = [...branches,old];
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
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
