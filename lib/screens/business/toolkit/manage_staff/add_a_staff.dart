import 'package:enum_to_string/enum_to_string.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:thephonenumber/thephonenumber.dart';

import '../../../../classes/firebase_structures/business_services.dart';
import '../../../../classes/firebase_structures/business_staff.dart';
import '../../../../config/config_data_types.dart';
import '../../../../helpers/helper.dart';
import '../../../../route_manager.dart';
import '../../../../stores/business_store.dart';
import '../../../../stores/cloud_store.dart';
import '../../../../widgets/buttons.dart';
import '../../../../widgets/loading_stack.dart';
import '../../../../widgets/multiple_option_chips.dart';
import '../../../../widgets/shake_widget.dart';
import '../../../../widgets/tiles/add_image_sliver.dart';

class BusinessAddAStaffScreen extends StatefulWidget {
  BusinessAddAStaffScreen({Key key}) : super(key: key);

  @override
  _BusinessAddAStaffScreenState createState() =>
      _BusinessAddAStaffScreenState();
}

class _BusinessAddAStaffScreenState extends State<BusinessAddAStaffScreen> {
  final _key = GlobalKey<FormState>();
  final _staff = BusinessStaff(dateOfJoining: DateTime.now());
  var selected = -1;
  final _doShakeImage = Observable(false);
  String authorizedUid = "";
  bool _numberValidated = false;
  ThePhoneNumber _theNumber;
  final _pnController = TextEditingController();

  @override
  void dispose() {
    _pnController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return LoadingStackWidget(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text("Add a Staff"),
        ),
        body: CustomScrollView(
          slivers: [
            Form(
              key: _key,
              child: SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      DropdownButtonFormField<UserType>(
                        value: _staff.role,
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
                      const SizedBox(
                        height: 20,
                      ),
                      Consumer<CloudStore>(
                        builder: (_, cloudStore, __) {
                          return InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber value) {
                              _pnController.text = value.phoneNumber;
                            },
                            inputDecoration:
                                const InputDecoration(labelText: "Bapp user"),
                            countries: [cloudStore.theNumber.iso2Code],
                            initialValue: PhoneNumber(
                                phoneNumber:
                                    _theNumber?.internationalNumber ?? ""),
                            onInputValidated: (b) async {
                              if (b != _numberValidated) {
                                setState(() {
                                  _numberValidated = b;
                                  _theNumber = ThePhoneNumberLib.parseNumber(
                                      internationalNumber: _pnController.text);
                                });
                              }
                            },
                            validator: (s) {
                              if (_numberValidated) {
                                return null;
                              }
                              return "Enter a valid number";
                            },
                          );
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: "Name of the staff"),
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
                      const SizedBox(
                        height: 20,
                      ),
                      InputDatePickerFormField(
                        fieldLabelText: "Date of joining",
                        firstDate: DateTime(2000),
                        initialDate: DateTime.now(),
                        lastDate: DateTime.now(),
                        onDateSubmitted: (date) {
                          _staff.dateOfJoining = date;
                        },
                        errorFormatText: "Select a date",
                      ),
                      const SizedBox(
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
                                placeHolder: "No service categories",
                                onAddPressed: () async {
                                  await Navigator.of(context).pushNamed(
                                      (RouteManager.businessAddAServiceCategoryScreen));
                                  setState(() {});
                                },
                                itemLabel: (_, cat) {
                                  return cat.categoryName.value;
                                },
                                validator: (s) {
                                  if (s.isEmpty) {
                                    return "Select at-least a expertise";
                                  }
                                  return null;
                                },
                                onSaved: (s) {},
                                onChanged: (val) {
                                  selected.clear();
                                  selected.addAll(val);
                                  _staff.expertise.clear();
                                  _staff.expertise.addAll(val);
                                },
                                items: businessStore.business.selectedBranch
                                    .value.businessServices.value.allCategories,
                                selectedItems: selected,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Observer(
                        builder: (_) {
                          return ShakeWidget(
                            doShake: _doShakeImage.value,
                            onShakeDone: () {
                              act(() {
                                _doShakeImage.value = false;
                              });
                            },
                            child: AddImageTileWidget(
                              title: "Add an image",
                              subTitle: "maximum of 1 image",
                              padding: EdgeInsets.zero,
                              maxImage: 1,
                              existingImages: _staff.images,
                              onImagesSelected: (imgs) {
                                _staff.images = imgs;
                              },
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      PrimaryButton(
                        "Add",
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (_key.currentState.validate()) {
                            if (_staff.images.isEmpty) {
                              act(() {
                                _doShakeImage.value = true;
                              });
                              return;
                            }
                            final branch = Provider.of<BusinessStore>(context,
                                    listen: false)
                                .business
                                .selectedBranch
                                .value;
                            if (branch.staff.isNotEmpty &&
                                branch.staff.any((s) =>
                                    s?.name == _staff.name ||
                                    s.contactNumber?.internationalNumber ==
                                        _theNumber?.internationalNumber)) {
                              Flushbar(
                                message: "That user details exists",
                                duration: const Duration(seconds: 2),
                              ).show(context);
                              return;
                            }
                            act(() {
                              kLoading.value = true;
                            });
                            _theNumber = ThePhoneNumberLib.parseNumber(internationalNumber: _pnController.text);
                            assert(_theNumber?.internationalNumber != null,
                                "number missing");
                            await branch.addAStaff(
                              userPhoneNumber: _theNumber,
                              name: _staff.name,
                              role: _staff.role,
                              dateOfJoining: _staff.dateOfJoining,
                              images: _staff.images,
                              expertise: _staff.expertise,
                            );
                            Navigator.of(context).pop();
                            act(() {
                              kLoading.value = false;
                            });
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
