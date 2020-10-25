import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/firebase_structures/business_category.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:bapp/stores/firebase_structures/business_staff.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:bapp/widgets/padded_text.dart';
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
                      decoration: InputDecoration(labelText: "Role"),
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
                      fieldLabelText: "Date of joining",
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      onDateSubmitted: (date) {
                        _staff.dateOfJoining = date;
                      },
                      errorFormatText: "Select a date",
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Consumer<BusinessStore>(
                      builder: (_, businessStore, __) {
                        final selected =
                            ObservableList<BusinessServiceCategory>();
                        return Observer(
                          builder: (_) {
                            return MultipleChipOptionsFormField<
                                BusinessServiceCategory>(
                              labelText: "Select staff expertise",
                              itemLabel: (_, cat) {
                                return cat.categoryName.value;
                              },
                              validator: (s) {
                                if (s.isEmpty) {
                                  return "Select a expertise";
                                }
                                return null;
                              },
                              onSaved: (s) {
                                _staff.expertise.clear();
                                _staff.expertise.addAll(s);
                              },
                              onChanged: (val) {
                                selected.clear();
                                selected.addAll(val);
                              },
                              items: businessStore.business.businessServices
                                  .value.allCategories,
                              selectedItems: selected,
                            );
                          },
                        );
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
                    PrimaryButton("Add", onPressed: () {
                      if (_key.currentState.validate()) {}
                    })
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

class MultipleChipOptionsFormField<T> extends FormField<List<T>> {
  final List<T> items;
  final Function(List<T>) onSaved;
  final Function(List<T>) onChanged;
  final String Function(List<T>) validator;
  final String Function(int, T) itemLabel;
  final List<T> selectedItems;
  final String labelText;

  MultipleChipOptionsFormField(
      {this.selectedItems,
      this.labelText,
      this.onChanged,
      this.itemLabel,
      this.items,
      this.onSaved,
      this.validator,
      Key key})
      : super(
          key: key,
          autovalidateMode: AutovalidateMode.disabled,
          onSaved: onSaved,
          validator: validator,
          initialValue: [],
          builder: (state) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(state.context).primaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  PaddedText(
                    labelText,
                  ),
                  ChipsChoice<T>.multiple(
                    value: selectedItems,
                    onChanged: (val) {
                      state.didChange(val);
                      onChanged(val);
                    },
                    choiceItems: C2Choice.listFrom<T, T>(
                      source: items,
                      value: (_, v) => v,
                      label: itemLabel,
                    ),
                  ),
                  if (state.hasError)
                    PaddedText(
                      state.errorText,
                      style: Theme.of(state.context)
                          .textTheme
                          .bodyText1
                          .apply(color: Theme.of(state.context).errorColor),
                    ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            );
          },
        );
}
