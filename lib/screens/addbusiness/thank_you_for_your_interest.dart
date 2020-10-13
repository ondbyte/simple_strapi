import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/shake_widget.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class ThankYouForYourInterestScreen extends StatefulWidget {
  final BusinessCategory category;

  const ThankYouForYourInterestScreen({Key key, this.category})
      : super(key: key);
  @override
  _ThankYouForYourInterestScreenState createState() =>
      _ThankYouForYourInterestScreenState();
}

class _ThankYouForYourInterestScreenState
    extends State<ThankYouForYourInterestScreen> {
  PhoneNumber _validNumber;
  bool _canVerify = false;
  PickedLocation _pickedLocation;
  bool _shake = false;
  String _businessName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: StoreProvider<CloudStore>(
          store: Provider.of<CloudStore>(context, listen: false),
          builder: (_, cloudStore) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Thank you for your interest",
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Please send us below information and we will on-board you as quickly as possible",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onChanged: (s) {
                    setState(() {
                      _businessName = s;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Name of your business",
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    _validNumber = number;
                  },
                  onInputValidated: (bool value) {
                    print(value);
                    if (_canVerify == !value) {
                      setState(() {
                        _canVerify = value;
                      });
                    }
                  },
                  selectorConfig: SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  ),
                  ignoreBlank: true,
                  initialValue:
                      _validNumber != null ? _validNumber : cloudStore.number,
                ),
                SizedBox(
                  height: 20,
                ),
                ShakeWidget(
                  doShake: _shake,
                  onShakeDone: () {
                    setState(
                      () {
                        _shake = false;
                      },
                    );
                  },
                  child: ListTile(
                    onTap: () async {
                      final tmp = await Navigator.of(context)
                          .pushNamed(RouteManager.pickALocation);
                      if (tmp != null) {
                        setState(() {
                          _pickedLocation = tmp;
                        });
                      }
                    },
                    contentPadding: EdgeInsets.only(left: 0),
                    trailing: Icon(Icons.arrow_forward_ios),
                    title: Text(
                      "Where is your business located",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    subtitle: Text(
                      _pickedLocation == null
                          ? "Pick an Address"
                          : _pickedLocation.address,
                      style: Theme.of(context).textTheme.bodyText1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Spacer(),
                MaterialButton(
                  onPressed: (_canVerify && _businessName.length > 2)
                      ? () {
                          if (_pickedLocation != null) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              RouteManager.contextualMessage,
                              (route) =>
                                  route.settings.name == RouteManager.home,arguments: [
                                  () async {
                                final tmp = await Provider.of<BusinessStore>(context,listen: false).applyForBusiness(
                                    BusinessDetails(
                                        uid: FirebaseAuth.instance.currentUser.uid,
                                        contactNumber: _validNumber.phoneNumber,
                                        category: widget.category,
                                        address: _pickedLocation.address,
                                        businessName: _businessName,
                                        latlong: _pickedLocation.latLong
                                    )
                                );
                                return tmp;
                              },
                              "Thank you, we\'ll reach you out soon"
                            ]
                            );
                          } else {
                            setState(
                              () {
                                _shake = true;
                              },
                            );
                          }
                        }
                      : null,
                  child: Row(
                    children: [
                      Text("Submit"),
                      Spacer(),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
