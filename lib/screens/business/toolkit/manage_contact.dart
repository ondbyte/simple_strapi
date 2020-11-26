import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/business_store.dart';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:thephonenumber/thecountrynumber.dart';

class BusinessManageContactDetailsScreen extends StatefulWidget {
  @override
  _BusinessManageContactDetailsScreenState createState() => _BusinessManageContactDetailsScreenState();
}

class _BusinessManageContactDetailsScreenState extends State<BusinessManageContactDetailsScreen> {
  TheNumber _enteredNumber,_previousNumber;
  bool _correct = false;
  String _email = "", _previousEmail = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,

      ),
      body: WillPopScope(
        onWillPop: () async {
          final businessStore = Provider.of<BusinessStore>(context,listen: false);
          if(_email.indexOf("@")<_email.lastIndexOf(".")){
            if(_previousEmail!=_email){
              await act((){
                businessStore.business.selectedBranch.value.email.value = _email;
              },);
            }
          }
          if(_correct){
            if(_previousNumber.internationalNumber!=_enteredNumber.internationalNumber){
              await act((){
                businessStore.business.selectedBranch.value.contactNumber.value = _enteredNumber.internationalNumber;
              });
            }
          }
          return true;
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text("How can your customers reach you?",style: Theme.of(context).textTheme.headline1,),
              SizedBox(height: 20,),
              Consumer<BusinessStore>(builder: (_,businessStore,__){
                _previousEmail = businessStore.business.selectedBranch.value.email.value;
                return TextFormField(
                  initialValue: _previousEmail,
                  decoration: InputDecoration(
                    labelText: "Email"
                  ),
                  onChanged: (s){
                    _email = s;
                  },
                );
              },),
              const SizedBox(height: 20,),
              Consumer<BusinessStore>(builder: (_,businessStore,__){
                _previousNumber = TheCountryNumber().parseNumber(internationalNumber: businessStore.business.selectedBranch.value.contactNumber.value);
                //print(_enteredNumber);
                return InternationalPhoneNumberInput(

                  inputDecoration: const InputDecoration(
                    labelText: "phone number",
                  ),
                  onInputChanged: (pn){
                    _enteredNumber = TheCountryNumber().parseNumber(internationalNumber: pn.phoneNumber);
                  },
                  initialValue: PhoneNumber(phoneNumber: _previousNumber.number,isoCode: _previousNumber.country.iso2),
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  onInputValidated: (b){
                    _correct = b;
                  },
                );
              },),
            ],
          ),
        ),
      ),
    );
  }
}

