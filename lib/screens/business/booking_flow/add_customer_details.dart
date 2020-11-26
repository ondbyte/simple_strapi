import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:thephonenumber/thecountrynumber.dart';

class AddCustomerDetails extends StatelessWidget {
  final _theNumber = Observable<TheNumber>(null);
  var _num = "";
  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<BookingFlow>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add customer details"),
        automaticallyImplyLeading: true,
      ),
      bottomNavigationBar: Observer(builder: (_) {
        return BottomPrimaryButton(
          label: "Confirm booking",
          onPressed: _theNumber.value == null
              ? null
              : () async {
                  await BappNavigator.bappPushAndRemoveAll(
                    context,
                    ContextualMessageScreen(
                      message: "Successfully added a walk-in booking",
                      buttonText: "Go to Home",
                      init: () async {
                        await flow.done(number: _theNumber.value);
                      },
                      onButtonPressed: (context) {
                        BappNavigator.bappPushAndRemoveAll(context, Bapp());
                      },
                    ),
                  );
                },
        );
      }),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: InternationalPhoneNumberInput(
            onInputChanged: (pn) {
              _num = pn.phoneNumber;
            },
            onInputValidated: (b) {
              act(() {
                if (b) {
                  _theNumber.value =
                      TheCountryNumber().parseNumber(internationalNumber: _num);
                  FocusScope.of(context).unfocus();
                } else {
                  _theNumber.value = null;
                }
              });
            },
            inputDecoration: InputDecoration(labelText: "Mobile number"),
          ),
        ),
      ),
    );
  }
}
