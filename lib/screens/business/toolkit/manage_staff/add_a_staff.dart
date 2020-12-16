import 'package:bapp/helpers/extensions.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:the_country_number_widgets/the_country_number_widgets.dart';
import 'package:thephonenumber/thecountrynumber.dart';

import '../../../../classes/firebase_structures/business_staff.dart';
import '../../../../config/config_data_types.dart';
import '../../../../config/config_data_types.dart';
import '../../../../config/config_data_types.dart';
import '../../../../config/config_data_types.dart';
import '../../../../helpers/helper.dart';
import '../../../../helpers/helper.dart';
import '../../../../stores/business_store.dart';
import '../../../../stores/cloud_store.dart';
import '../../../../widgets/buttons.dart';
import '../../../../widgets/loading_stack.dart';
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
  TheNumber _theNumber;


  @override
  void initState() {
    super.initState();
    act((){
      kLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingStackWidget(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text("Add a Staff"),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: CustomScrollView(
            slivers: [
              Consumer2<CloudStore, BusinessStore>(
                builder: (_, cloudStore, businessStore, __) {
                  return Form(
                    key: _key,
                    child: SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            DropdownButtonFormField<UserType>(
                              value: _staff.role,
                              selectedItemBuilder: (_) {
                                final ws = <Widget>[];
                                final list = [
                                  UserType.businessManager,
                                  UserType.businessReceptionist,
                                  UserType.businessStaff
                                ];
                                list.forEach((element) {
                                  ws.add(Text(readableEnum(element)));
                                });
                                return ws;
                              },
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
                            TheCountryNumberInput(
                              cloudStore.theNumber.removeNumber(),
                              decoration: TheInputDecor(labelText: "Bapp user"),
                              customValidator: (tn) {
                                if (tn != null) {
                                  if (businessStore
                                      .business.selectedBranch.value
                                      .anyStaffHasNumber(tn)) {
                                    return "Existing staff";
                                  }
                                  if (tn.validLength) {
                                    return null;
                                  }
                                }
                                return "Enter a valid number";
                              },
                              onChanged: (tn) {
                                setState(
                                  () {
                                    _theNumber = tn;
                                    _numberValidated = tn.validLength;
                                  },
                                );
                              },
                            ),
                            
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: "Name of the staff"),
                              onChanged: (s) {
                                _staff.name = s;
                              },
                              validator: (s) {
                                if (s.isEmpty) {
                                  return "Enter a name";
                                }
                                if (businessStore.business.selectedBranch.value
                                    .anyStaffHasName(s)) {
                                  return "Staff exists";
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
                                return TextFieldTags(
                                  textFieldStyler: TextFieldStyler(hintText: "Add Skills / Specialization", ),
                                  onTag: (s) {
                                    _staff.expertise.add(s);
                                  },
                                  onDelete: (s) {
                                    _staff.expertise.remove(s);
                                  },
                                  tagsStyler: TagsStyler(
                                    tagCancelIcon: Icon(
                                      FeatherIcons.x,
                                      color: Theme.of(context).indicatorColor,
                                    ),
                                    tagTextStyle: TextStyle(
                                        color:
                                            Theme.of(context).indicatorColor),
                                    tagDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
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
                                  final branch = Provider.of<BusinessStore>(
                                          context,
                                          listen: false)
                                      .business
                                      .selectedBranch
                                      .value;
                                  if (branch.staff.isNotEmpty &&
                                      branch.staff.any((s) =>
                                          s?.name == _staff.name ||
                                          s.contactNumber
                                                  ?.internationalNumber ==
                                              _theNumber
                                                  ?.internationalNumber)) {
                                    Flushbar(
                                      message: "That user details exists",
                                      duration: const Duration(seconds: 2),
                                    ).show(context);
                                    return;
                                  }
                                  act(() {
                                    kLoading.value = true;
                                  });
                                  assert(
                                      _theNumber?.internationalNumber != null,
                                      "number missing");
                                  await branch.addAStaff(
                                    userPhoneNumber: _theNumber,
                                    name: _staff.name,
                                    role: _staff.role,
                                    dateOfJoining: _staff.dateOfJoining,
                                    images: _staff.images,
                                    expertise: _staff.expertise,
                                  );
                                  BappNavigator.pop(context, null);
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
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
