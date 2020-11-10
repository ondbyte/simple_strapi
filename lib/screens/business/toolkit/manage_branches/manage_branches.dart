import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/firebase_structures/business_branch.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class BusinessManageBranchesScreen extends StatefulWidget {
  BusinessManageBranchesScreen({Key key}) : super(key: key);

  @override
  _BusinessManageBranchesScreenState createState() =>
      _BusinessManageBranchesScreenState();
}

class _BusinessManageBranchesScreenState
    extends State<BusinessManageBranchesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final branches = Provider.of<BusinessStore>(context, listen: false)
              .business
              .branches
              .value;
          if (branches.any((element) =>
              element.status.value == BusinessBranchActiveStatus.published)) {
            Navigator.of(context)
                .pushNamed(RouteManager.businessAddABranchScreeen);
          } else {
            Flushbar(
              message:
                  "Your new business needs to have atleast one approved branch to add more branches",
              duration: const Duration(seconds: 4),
            ).show(context);
          }
        },
        child: Icon(
          Icons.add,
          color: Theme.of(context).indicatorColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Manage Branches"),
      ),
      body: Consumer<BusinessStore>(
        builder: (_, businessStore, __) {
          return Observer(
            builder: (_) {
              final branches = businessStore.business.branches.value;
              return ListView.builder(
                itemCount: branches.length,
                itemBuilder: (_, i) {
                  return ListTile(
                    leading: FirebaseStorageImage(
                      storagePathOrURL: branches[i].images.isNotEmpty
                          ? branches[i].images.keys.elementAt(0)
                          : kTemporaryBusinessImage,
                      height: 80,
                      width: 80,
                    ),
                    title: Text(branches[i].name.value),
                    subtitle: Text(removeNewLines(branches[i].address.value)),
                    trailing: IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: () async {
                          final remove = await showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text("Remove?"),
                                content: Text(
                                    "Would you like to remove the fallowing branch from your business?"),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Text("Remove"),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: Text("Cancel"),
                                  ),
                                ],
                              );
                            },
                          );
                          if (remove != null && remove) {
                            if (branches.length == 1) {
                              Flushbar(
                                message:
                                    "A business should have atleast 1 branch, contact customer care to de-list your business.",
                                duration: Duration(seconds: 4),
                              ).show(context);
                            } else {
                              await businessStore.business
                                  .removeBranch(branches[i]);
                            }
                          }
                        }),
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
