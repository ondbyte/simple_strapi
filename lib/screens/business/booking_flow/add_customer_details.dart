import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

import 'package:the_country_number/the_country_number.dart';
import 'package:the_country_number_widgets/the_country_number_widgets.dart';

class AddCustomerDetails extends StatelessWidget {
  final _userName = Rx<TheNumber?>(null);
  final _loading = Rx<bool>(false);
  final _key = GlobalKey<FormState>();
  String _email = "",
      _name = "",
      _website = "",
      _facebook = "",
      _instagram = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add customer details"),
        automaticallyImplyLeading: true,
      ),
      bottomNavigationBar: Obx(() {
        return BottomPrimaryButton(
          label: "Confirm booking",
          onPressed: _userName() is TheNumber
              ? () async {
                  if (_key.currentState?.validate() ?? false) {
                    var user = await UserX.i.getOtherUserFromUserName(
                        _userName()!.internationalNumber);
                    if (user is! User) {
                      user = User.fresh(
                        username: _userName()!.internationalNumber,
                      );
                    }
                    BappNavigator.pop(context, user);
                  }
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
                        internationalNumber: UserX.i.user()!.username,
                      )
                      .removeNumber()!,
                  onChanged: (tn) {
                    _userName(tn);
                  },
                  customValidator: (tn) {
                    if (tn.isValidLength) {
                      return null;
                    }
                    return "Enter a valid number";
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
