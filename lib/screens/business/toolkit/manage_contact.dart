import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_country_number_widgets/the_country_number_widgets.dart';
import 'package:thephonenumber/thecountrynumber.dart';

class BusinessManageContactDetailsScreen extends StatefulWidget {
  @override
  _BusinessManageContactDetailsScreenState createState() =>
      _BusinessManageContactDetailsScreenState();
}

class _BusinessManageContactDetailsScreenState
    extends State<BusinessManageContactDetailsScreen> {
  TheNumber _enteredNumber, _previousNumber;
  bool _correct = false;
  String _email = "", _previousEmail = "";

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessStore>(
      builder: (_, businessStore, __) {
        _previousEmail =
            businessStore.business.selectedBranch.value.email.value;
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
          ),
          bottomNavigationBar: BottomPrimaryButton(
            label: "Update",
            onPressed: () {
              act(
                () {
                  businessStore.business.selectedBranch.value.email.value =
                      _email;
                  businessStore.business.selectedBranch.value.contactNumber
                      .value = _enteredNumber.internationalNumber;
                },
              );
            },
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "How can your customers reach you?",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    initialValue: _previousEmail,
                    decoration: InputDecoration(labelText: "Email"),
                    onChanged: (s) {
                      _email = s;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TheCountryNumberInput(
                    _previousNumber,
                    decoration: TheInputDecor(labelText: "PhoneNumber"),
                    onChanged: (tn) {
                      _enteredNumber = tn;
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
