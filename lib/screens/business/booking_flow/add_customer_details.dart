import 'package:bapp/classes/firebase_structures/bapp_user.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:the_country_number_widgets/the_country_number_widgets.dart';
import 'package:thephonenumber/thecountrynumber.dart';

class AddCustomerDetails extends StatelessWidget {
  final _theNumber = Observable<TheNumber>(null);
  final _key = GlobalKey<FormState>();
  String _email = "",
      _name = "",
      _website = "",
      _facebook = "",
      _instagram = "";

  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<BookingFlow>(context);
    return Consumer2<BusinessStore, CloudStore>(
        builder: (_, businessStore, cloudStore, __) {
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
                    var user = await cloudStore.getUserForNumber(
                        number: _theNumber.value.internationalNumber);
                    if (user == null) {
                      user = BappUser(
                        myDoc: BappUser.newReference(),
                        email: _email,
                        facebook: _facebook,
                        instagram: _instagram,
                        name: _name,
                        theNumber: _theNumber.value,
                        website: _website,
                      );
                    } else {
                      user = user.updateWith(
                          instagram: _instagram,
                          facebook: _facebook,
                          website: _website);
                    }
                    user.save();
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TheCountryNumberInput(
                    TheCountryNumber()
                        .parseNumber(
                          internationalNumber:
                              businessStore.business.contactNumber.value,
                        )
                        .removeNumber(),
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
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Email"),
                    onChanged: (s) {
                      _email = s;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Name"),
                    onChanged: (s) {
                      _name = s;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Website"),
                    onChanged: (s) {
                      _website = s;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Facebook"),
                    onChanged: (s) {
                      _facebook = s;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Instagram"),
                    onChanged: (s) {
                      _instagram = s;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
