import 'package:bapp/classes/firebase_structures/business_category.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/location/pick_a_location.dart';

import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/shake_widget.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:bapp/widgets/wheres_it_located.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:thephonenumber/thecountrynumber.dart';


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
  TheNumber _validNumber;
  bool _canVerify = false;
  PickedLocation _pickedLocation;
  bool _shake = false;
  String _businessName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StoreProvider<CloudStore>(
        store: Provider.of<CloudStore>(context, listen: false),
        builder: (_, cloudStore) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
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
                      decoration: const InputDecoration(
                        labelText: "Name of your business",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        _validNumber = TheCountryNumber().parseNumber(
                          internationalNumber: number.phoneNumber,
                        );
                      },
                      onInputValidated: (bool value) {
                        if (_canVerify == !value) {
                          setState(
                            () {
                              _canVerify = value;
                            },
                          );
                        }
                      },
                      selectorConfig: const SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      ),
                      ignoreBlank: true,
                      initialValue: PhoneNumber(
                        phoneNumber: cloudStore.theNumber.number,
                        isoCode: cloudStore.theNumber.country.iso2,
                      ),
                    ),
                    const SizedBox(
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
                      child: WheresItLocatedTileWidget(
                        onPickLocation: (p) {
                          _pickedLocation = p;
                        },
                      ),
                    ),
                  ]),
                ),
              )
            ],
          );
        },
      ),
      bottomSheet: MaterialButton(
        onPressed: (_canVerify && _businessName.length > 2)
            ? () {
                if (_pickedLocation != null) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteManager.contextualMessage,
                    (route) => route.settings.name == RouteManager.home,
                    arguments: [
                      () async {
                        final tmp = await Provider.of<BusinessStore>(context,
                                listen: false)
                            .applyForBusiness(
                          latlong: _pickedLocation.latLong,
                          address: _pickedLocation.address,
                          businessName: _businessName,
                          contactNumber: _validNumber.internationalNumber,
                          category: widget.category,
                        );
                        return tmp;
                      },
                      "Thank you, we\'ll reach you out soon"
                    ],
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
      ),
    );
  }
}
