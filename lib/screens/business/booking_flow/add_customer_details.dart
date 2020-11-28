import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:the_country_number_widgets/the_country_number_widgets.dart';
import 'package:thephonenumber/thecountrynumber.dart';

class AddCustomerDetails extends StatelessWidget {
  final _theNumber = Observable<TheNumber>(null);
  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<BookingFlow>(context);
    return Consumer<BusinessStore>(builder: (_, businessStore, __) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Add customer details"),
          automaticallyImplyLeading: true,
        ),
        bottomNavigationBar: Observer(builder: (_) {
          return BottomPrimaryButton(
            label: "Confirm booking",
            onPressed: _theNumber.value != null && _theNumber.value.validLength
                ? () async {
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
                  }
                : null,
          );
        }),
        body: Form(
          key: _key,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topCenter,
              child: TheCountryNumberInput(
                TheCountryNumber().parseNumber(
                    internationalNumber:
                        businessStore.business.contactNumber.value),
                onChanged: (tn) {
                  act(() {
                    _theNumber.value = tn;
                  });
                },
                customValidator: (tn) {
                  if (tn != null) {
                    if (tn.validLength) {
                      return null;
                    }
                  }
                  return "Enter a valid number";
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}
