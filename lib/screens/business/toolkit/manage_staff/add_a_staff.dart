import 'package:bapp/FCM.dart';
import 'package:bapp/classes/notification_update.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/firebase_structures/bapp_user.dart';
import 'package:bapp/stores/firebase_structures/business_category.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:bapp/stores/firebase_structures/business_staff.dart';
import 'package:bapp/widgets/add_image_sliver.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:bapp/widgets/multiple_option_chips.dart';
import 'package:bapp/widgets/padded_text.dart';
import 'package:bapp/widgets/shake_widget.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:mobx/mobx.dart';
import 'package:thephonenumber/thephonenumber.dart';

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
  final _doShakeImage = Observable(false);
  ThePhoneNumber _theNumber;
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
                      Consumer<CloudStore>(
                        builder: (_, cloudStore, __) {
                          return InternationalPhoneNumberInput(
                            inputDecoration:
                                InputDecoration(labelText: "Bapp user"),
                            countries: [cloudStore.theNumber.iso2Code],
                            onInputChanged: (pn) {
                              _theNumber = ThePhoneNumberLib.parseNumber(
                                  internationalNumber: pn.phoneNumber);
                            },
                            onInputValidated: (b) async {
                              if (b) {
                                await _getStaffAuthorization();
                              }
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
                                    return "Select atleast a expertise";
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
                        onPressed: () {
                          if (_key.currentState.validate()) {
                            if (_staff.images.isEmpty) {
                              act(() {
                                _doShakeImage.value = true;
                              });
                              return;
                            }
                            act(() {
                              kLoading.value = true;
                            });
                            final branch = Provider.of<BusinessStore>(context)
                                .business
                                .selectedBranch
                                .value;
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

  Future _getStaffAuthorization() async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          //title: Text(_theNumber.internationalNumber),
          content: BusinessAskUserForStaffingWidget(
            thePhoneNumber: _theNumber,
          ),
        );
      },
    );
  }
}

class BusinessAskUserForStaffingWidget extends StatefulWidget {
  final ThePhoneNumber thePhoneNumber;
  BusinessAskUserForStaffingWidget({Key key, @required this.thePhoneNumber})
      : super(key: key);

  @override
  _BusinessAskUserForStaffingWidgetState createState() =>
      _BusinessAskUserForStaffingWidgetState();
}

class _BusinessAskUserForStaffingWidgetState
    extends State<BusinessAskUserForStaffingWidget> {

  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CloudStore, BusinessStore>(
      builder: (_, cloudStore, businessStore, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Press ask now to ask the Bapp user with the number ${widget.thePhoneNumber.internationalNumber} to join your business on Bapp"),
            SizedBox(
              height: 20,
            ),
            _loading?LoadingWidget():PrimaryButton(
              "Ask now",
              onPressed: () async {
                _loading = false;
                final response = await cloudStore.getAuthorizationForStaffing(
                  phoneNumber: widget.thePhoneNumber,
                  business: businessStore.business,
                  onReplyRecieved: (bappMessage) {
                    if(bappMessage==null){
                      Navigator.of(context).pop();
                      Flushbar(message: "Time out",duration: const Duration(seconds: 2),).show(context);
                    } else {
                      if(bappMessage.type==BappFCMMessageType.ac)
                    }
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
