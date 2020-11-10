import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class BusinessManageStaffScreen extends StatefulWidget {
  BusinessManageStaffScreen({Key key}) : super(key: key);

  @override
  _BusinessManageStaffScreenState createState() =>
      _BusinessManageStaffScreenState();
}

class _BusinessManageStaffScreenState extends State<BusinessManageStaffScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Staff manager"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Theme.of(context).indicatorColor,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(RouteManager.businessAddAStaffScreen);
        },
      ),
      body: Consumer<BusinessStore>(
        builder: (_, businessStore, __) {
          return Observer(builder: (_) {
            final staffs = businessStore.business.selectedBranch.value.staff;
            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ...List.generate(
                        staffs.length,
                        (index) => ListTile(
                          title: Text(staffs[index].name),
                          subtitle: Text(EnumToString.convertToString(staffs[index].role)),
                          trailing: IconButton(icon: Icon(Icons.delete,),onPressed: () async {
                            await businessStore.business.selectedBranch.value.removeAStaff(staffs[index]);
                          },),
                          leading: FirebaseStorageImage(
                            circular: true,
                            width: 64,
                            height: 64,
                            storagePathOrURL: staffs[index].images.keys.elementAt(0),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}
