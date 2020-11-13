import 'package:bapp/FCM.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:bapp/stores/firebase_structures/business_staff.dart';
import 'package:bapp/widgets/add_image_sliver.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:bapp/widgets/multiple_option_chips.dart';
import 'package:bapp/widgets/shake_widget.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:thephonenumber/thephonenumber.dart';

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
                        value: _staff.role??null,
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
                            inputDecoration:
                                const InputDecoration(labelText: "Bapp user"),
                            countries: [cloudStore.theNumber.iso2Code],
                            onInputChanged: (pn) {
                              _theNumber = ThePhoneNumberLib.parseNumber(
                                  internationalNumber: pn.phoneNumber);
                            },
                            initialValue: PhoneNumber(phoneNumber: _theNumber?.internationalNumber??""),
                            onInputValidated: (b) async {
                              if (b != _numberValidated) {
                                setState(() {
                                  _numberValidated = b;
                                });
                              }
                            },
                            validator: (s){
                              if(_numberValidated){
                                return null;
                              }
                              return "Enter a valid number";
                            },
                          );
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      /*FlatButton.icon(
                        onPressed: authorizedUid.isNotEmpty
                            ? _numberValidated
                                ? () {
                                    Flushbar(
                                      message:
                                          "User acknowledged the staffing request",
                                      duration: const Duration(seconds: 2),
                                    ).show(context);
                                  }
                                : null
                            : _numberValidated
                                ? () async {
                                    if (_theNumber.internationalNumber ==
                                        Provider.of<CloudStore>(context,
                                                listen: false)
                                            .theNumber
                                            .internationalNumber) {
                                      ///cannot use own number
                                      Flushbar(
                                        message: "Cannot be your number",
                                        duration: const Duration(seconds: 2),
                                      ).show(context);
                                      return;
                                    }
                                    authorizedUid =
                                        (await _getStaffAuthorization()) ?? "";
                                    setState(() {

                                    });
                                  }
                                : null,
                        icon: Icon(FeatherIcons.user),
                        textTheme: ButtonTextTheme.primary,
                        label: Text(
                          authorizedUid.isNotEmpty
                              ? "Authorized"
                              : "Ask Authorization",
                        ),
                        color: authorizedUid.isNotEmpty
                            ? Colors.green
                            : Theme.of(context).errorColor,
                      ),*/
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
                                placeHolder: "No service categories",
                                onAddPressed: () async {
                                  await Navigator.of(context).pushNamed((RouteManager.businessAddAServiceCategoryScreen));
                                  setState(() {

                                  });
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
                                onSaved: (s) {
                                },
                                onChanged: (val) {
                                  selected.clear();
                                  selected.addAll(val);
                                  _staff.expertise.clear();
                                  _staff.expertise.addAll(val);
                                },
                                items: businessStore.business.selectedBranch.value.businessServices
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
                            if(branch.staff.isNotEmpty&&branch.staff.any((s) => s?.name==_staff.name||s.contactNumber?.internationalNumber==_theNumber?.internationalNumber)){
                              Flushbar(message: "That user details exists",duration: const Duration(seconds: 2),).show(context);
                              return;
                            }
                            act(() {
                              kLoading.value = true;
                            });
                            assert(_theNumber?.internationalNumber!=null,"number missing");
                            await branch.addAStaff(
                              userPhoneNumber: _theNumber,
                              name: _staff.name,
                              role: _staff.role,
                              dateOfJoining: _staff.dateOfJoining,
                              images: _staff.images,
                              expertise: _staff.expertise,
                            );
                            Navigator.of(context).pop();
                            act((){
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
/*
  Future<String> _getStaffAuthorization() async {
    return await showDialog<String>(
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
  }*/
}
/*

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
  bool _loading = false, _waiting = false;
  Widget _finallyWidget;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !_waiting;
      },
      child: Consumer2<CloudStore, BusinessStore>(
        builder: (_, cloudStore, businessStore, __) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _finallyWidget == null
                  ? Text(
                      "Press ask now to ask the Bapp user with the number ${widget.thePhoneNumber.internationalNumber} to join your business on Bapp",
                    )
                  : SizedBox(),
              SizedBox(
                height: _finallyWidget == null ? 20 : 0,
              ),
              _loading
                  ? LoadingWidget()
                  : _finallyWidget == null
                      ? PrimaryButton(
                          "Ask now",
                          onPressed: (){
                            _onPressed(businessStore, cloudStore);
                          },
                        )
                      : _finallyWidget,
            ],
          );
        },
      ),
    );
  }

  _onPressed(BusinessStore businessStore, CloudStore cloudStore) async {
    setState(() {
      _loading = true;
    });
    final response = await _askNow(businessStore, cloudStore);
    if (response == BappFunctionsResponse.multiUser ||
        response == BappFunctionsResponse.noUser) {
      _finallyWidget = Column(
        children: [
          Text("User is not on Bapp, please ask the user to sign up."),
          SizedBox(
            height: 20,
          ),
          PrimaryButton(
            "Go back",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    } else if (response == BappFunctionsResponse.success) {
      _finallyWidget = Column(
        children: [
          Text("User is on Bapp, we are reaching them out, please wait"),
          SizedBox(
            height: 20,
          ),
          LoadingWidget(),
        ],
      );
    } else if (response.contains(BappFunctionsResponse.invalidRecipient)) {
      _finallyWidget = Column(
        children: [
          Text(
              "Ask the user enable the notification in settings and press ask again"),
          SizedBox(
            height: 20,
          ),
          PrimaryButton(
            "Ask again",
            onPressed: (){
              _onPressed(businessStore, cloudStore);
            },
          ),
          FlatButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Text("Go back"),
          )
        ],
      );
    }
    setState(() {
      _loading = false;
    });
  }

  Future<String> _askNow(
      BusinessStore businessStore, CloudStore cloudStore) async {
    _waiting = true;
    final response = await cloudStore.getAuthorizationForStaffing(
      phoneNumber: widget.thePhoneNumber,
      business: businessStore.business,
      onReplyRecieved: (bappMessage) {
        if (bappMessage == null) {
          _finallyWidget = _onNull(businessStore, cloudStore);
        } else {
          if (bappMessage.type ==
              BappFCMMessageType.staffAuthorizationAskDeny) {
            _finallyWidget = _onDeny(businessStore, cloudStore);
          } else if (bappMessage.type ==
              BappFCMMessageType.staffAuthorizationAskAcknowledge) {
            //_finallyWidget = _onAcknowledge(businessStore, cloudStore);
            Helper.printLog("UID");
            print(bappMessage.data["uid"]);
            Navigator.of(context).pop(bappMessage.data["uid"]);
          }
        }
        setState(() {
          _loading = false;
        });
      },
    );
    return response;
  }
*/
/*
  Widget _onAcknowledge(BusinessStore businessStore, CloudStore cloudStore) {
    return Column(
      children: [
        Text(
          "User acknowledged",
          style:
              Theme.of(context).textTheme.headline1.apply(color: Colors.green),
        ),
        SizedBox(
          height: 20,
        ),
        PrimaryButton(
          "Go back",
          onPressed: () {
            Navigator.of(context).pop("");
          },
        )
      ],
    );
  }*//*


  Widget _onDeny(BusinessStore businessStore, CloudStore cloudStore) {
    return Column(
      children: [
        Text(
          "User denied your offer",
          style: Theme.of(context).textTheme.headline1.apply(color: Colors.red),
        ),
        SizedBox(
          height: 20,
        ),
        PrimaryButton(
          "Go back",
          onPressed: () {
            Navigator.of(context).pop("");
          },
        )
      ],
    );
  }

  Widget _onNull(BusinessStore businessStore, CloudStore cloudStore) {
    return Column(
      children: [
        Text(
          "Times up,",
          style: Theme.of(context).textTheme.headline1,
        ),
        SizedBox(
          height: 20,
        ),
        PrimaryButton(
          "Ask again",
          onPressed: (){
            _onPressed(businessStore, cloudStore);
          },
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop("");
          },
          child: Text("Go back"),
        )
      ],
    );
  }
}
*/
