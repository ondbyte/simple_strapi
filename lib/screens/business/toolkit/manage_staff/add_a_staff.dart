import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:bapp/stores/firebase_structures/business_staff.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:mobx/mobx.dart';

class BusinessAddAStaffScreen extends StatefulWidget {
  BusinessAddAStaffScreen({Key key}) : super(key: key);

  @override
  _BusinessAddAStaffScreenState createState() =>
      _BusinessAddAStaffScreenState();
}

class _BusinessAddAStaffScreenState extends State<BusinessAddAStaffScreen> {
  final _key = GlobalKey<FormState>();
  final _staff = BusinessStaff();
  var selected = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Add a Staff"),
      ),
      body: CustomScrollView(
        slivers: [
          Form(
            key: _key,
            child: SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    DropdownButtonFormField<UserType>(
                      items: [
                        DropdownMenuItem(
                          child: Text(
                            EnumToString.convertToString(
                              UserType.businessManager,
                            ),
                          ),
                          value: UserType.businessManager,
                        ),
                        DropdownMenuItem(
                          child: Text(
                            EnumToString.convertToString(
                              UserType.businessReceptionist,
                            ),
                          ),
                          value: UserType.businessReceptionist,
                        ),
                        DropdownMenuItem(
                          child: Text(
                            EnumToString.convertToString(
                              UserType.businessStaff,
                            ),
                          ),
                          value: UserType.businessStaff,
                        ),
                      ],
                      validator: (s) {
                        if (s == null) {
                          return "Select a role type";
                        }
                        return null;
                      },
                      onChanged: (s) {
                        _staff.role = s;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: "Name of the staff"),
                      onChanged: (s) {
                        _staff.name = s;
                      },
                      validator: (s) {
                        if (s.isEmpty) {
                          return "Enter a name";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InputDatePickerFormField(
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      onDateSubmitted: (date) {
                        _staff.dateOfJoining = date;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Consumer<BusinessStore>(
                      builder: (_, businessStore, __) {
                        final services =
                            businessStore.business.businessServices.value;
                        return Observer(
                          builder: (context) {
                            return ChipsChoice<
                                BusinessServiceCategory>.multiple(
                              value: _staff.expertise,
                              onChanged: (val) {
                                setState(() {
                                  _staff.expertise.clear();
                                  _staff.expertise.addAll(val);
                                });
                              },
                              choiceItems: C2Choice.listFrom<
                                      BusinessServiceCategory,
                                      BusinessServiceCategory>(
                                  source: services.allCategories,
                                  value: (_, v) => v,
                                  label: (_, l) => l.categoryName.value),
                            );
                          },
                        );
                      },
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: "Name of the staff"),
                      onChanged: (s) {
                        _staff.name = s;
                      },
                      validator: (s) {
                        if (s.isEmpty) {
                          return "Enter a name";
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
