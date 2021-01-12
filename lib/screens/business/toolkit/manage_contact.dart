import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_country_number/the_country_number.dart';
import 'package:the_country_number_widgets/the_country_number_widgets.dart';

class BusinessManageContactDetailsScreen extends StatefulWidget {
  @override
  _BusinessManageContactDetailsScreenState createState() =>
      _BusinessManageContactDetailsScreenState();
}

class _BusinessManageContactDetailsScreenState
    extends State<BusinessManageContactDetailsScreen> {
  TheNumber _enteredNumber, _previousNumber;
  bool _correct = false;
  String _email = "", _previousEmail = "", _website = "", _fb = "", _insta = "";

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessStore>(
      builder: (_, businessStore, __) {
        _previousEmail =
            businessStore.business.selectedBranch.value.email.value;
        _previousNumber = TheCountryNumber().parseNumber(
            internationalNumber: businessStore.business.contactNumber.value);
        _enteredNumber = _previousNumber;
        _email = _previousEmail;
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
                  businessStore.business.selectedBranch.value.website.value =
                      _website;
                  businessStore.business.selectedBranch.value.facebook.value =
                      _fb;
                  businessStore.business.selectedBranch.value.instagram.value =
                      _insta;
                  businessStore.business.selectedBranch.value.contactNumber
                      .value = _enteredNumber.internationalNumber;
                  BappNavigator.pop(context, null);
                },
              );
            },
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16,),
              child: SingleChildScrollView(
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
                          if (tn.isValidLength) {
                            return null;
                          }
                        }
                        return "Enter a valid number";
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      initialValue: () {
                        _website = businessStore
                            .business.selectedBranch.value.website.value;
                        return _website;
                      }(),
                      decoration: InputDecoration(
                        labelText: "Website",
                      ),
                      onChanged: (s) {
                        _website = s;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      initialValue: () {
                        _fb = businessStore
                            .business.selectedBranch.value.facebook.value;
                        return _fb;
                      }(),
                      decoration: InputDecoration(
                        labelText: "Facebook url",
                      ),
                      onChanged: (s) {
                        _fb = s;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      initialValue: () {
                        _insta = businessStore
                            .business.selectedBranch.value.instagram.value;
                        return _insta;
                      }(),
                      decoration: InputDecoration(
                        labelText: "Instagram url",
                      ),
                      onChanged: (s) {
                        _insta = s;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
