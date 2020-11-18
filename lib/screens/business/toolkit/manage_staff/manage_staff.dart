import 'package:bapp/classes/firebase_structures/business_staff.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:bapp/widgets/tabs/business_profile/services_tab.dart';
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
                        (index) => BusinessStaffListTile(
                          staff: staffs[index],
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                            ),
                            onPressed: () async {
                              await businessStore.business.selectedBranch.value
                                  .removeAStaff(
                                staffs[index],
                              );
                            },
                          ),
                        ),
                      ),
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

class BusinessStaffListTile extends StatelessWidget {
  final BusinessStaff staff;
  final Widget trailing;

  const BusinessStaffListTile({Key key, this.staff, this.trailing})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(staff.name),
      subtitle: Text(EnumToString.convertToString(staff.role)),
      trailing: trailing,
      leading: ListTileFirebaseImage(
        storagePathOrURL: staff.images.isNotEmpty?staff.images.keys.elementAt(0):kTemporaryPlaceHolderImage,
      ),
    );
  }
}
