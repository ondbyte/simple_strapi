import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/booking_flow/add_customer_details.dart';
import 'package:bapp/screens/business/business_profile/select_time_slot.dart';
import 'package:bapp/screens/business/business_profile/tabs/services_tab.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class BusinessProfileServicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<BookingFlow>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        automaticallyImplyLeading: true,
      ),
      bottomNavigationBar: Observer(builder: (_) {
        return BottomPrimaryButton(
          title: flow.selectedTitle.value.isNotEmpty
              ? flow.selectedTitle.value
              : null,
          subTitle: flow.selectedSubTitle.value.isNotEmpty
              ? flow.selectedSubTitle.value
              : null,
          label: "Add",
          onPressed: flow.services.isEmpty
              ? null
              : () {
                  BappNavigator.bappPush(context, SelectTimeSlotScreen(
                    onSelect: () {
                      BappNavigator.bappPush(context, AddCustomerDetails());
                    },
                  ));
                },
        );
      }),
      body: BusinessProfileServicesTab(),
    );
  }
}
