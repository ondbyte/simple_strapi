import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:intl_phone_number_input/intl_phone_number_input_test.dart';
import 'package:libphonenumber/libphonenumber.dart';
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
  final key = GlobalKey<FormState>();
  PhoneNumber _validNumber;
  bool _canVerify = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: StoreProvider<CloudStore>(
          store: Provider.of<CloudStore>(context),
          builder: (_, cloudStore) {
            return Form(
              key: key,
              child: Column(
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
                    validator: (s) {
                      if (s.length > 1) {
                        return null;
                      }
                      return "Enter a valid business name";
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
                      setState(
                            () {
                          _canVerify = value;
                        },
                      );
                    },
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    ignoreBlank: true,
                    initialValue: cloudStore.number
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    onTap: (){
                      Navigator.of(context).pushNamed("");
                    },
                    contentPadding: EdgeInsets.only(left: 0),
                    trailing: Icon(Icons.arrow_forward_ios),
                    title: Text(
                      "Where is your business located",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    subtitle: Text(
                      "Pick an Address",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  Spacer(),
                  if (_validNumber != null)
                    MaterialButton(
                      onPressed: () {
                        if (key.currentState.validate()) {

                        }
                      },
                      child: Row(
                        children: [
                          Text("Submit"),
                          Spacer(),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
