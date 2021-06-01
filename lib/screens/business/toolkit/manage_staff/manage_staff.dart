import 'package:bapp/classes/firebase_structures/business_staff.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/business/toolkit/manage_staff/add_a_staff.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessManageStaffScreen extends StatefulWidget {
  BusinessManageStaffScreen({Key? key}) : super(key: key);

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
          BappNavigator.push(context, BusinessAddAStaffScreen());
        },
      ),
      body: Builder(
        builder: (_) {
          return Builder(builder: (_) {
            final staffs = [];
            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ...List.generate(
                        staffs.length,
                        (index) => BusinessEmployeeListTile(
                          employee: staffs[index],
                          trailing: Builder(
                            builder: (_) {
                              return Switch(
                                value: staffs[index].enabled.value,
                                onChanged: (b) {
                                  act(() {
                                    staffs[index].enable(b);
                                  });
                                },
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

class BusinessEmployeeListTile extends StatelessWidget {
  final Employee employee;
  final Widget trailing;

  const BusinessEmployeeListTile(
      {Key? key, required this.employee, required this.trailing})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final me = true;
    return ListTile(
      title: Text(
        me ? "Me" : employee.name ?? "",
      ),
      subtitle: Text(
        "role name",
      ),
      trailing: trailing,
      leading: ListTileFirebaseImage(
        ifEmpty: Initial(
          forName: employee.name ?? "zz",
        ),
        storagePathOrURL: null,
      ),
    );
  }
}
