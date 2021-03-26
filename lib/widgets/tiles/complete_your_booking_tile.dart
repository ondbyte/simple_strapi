import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/business_profile/business_profile.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class CompleteYourBookingTile extends StatelessWidget {
  final EdgeInsets? padding;

  const CompleteYourBookingTile({Key? key, this.padding}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (_) {
        return SizedBox();
        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: RRShape(
            child: ListTile(
              title: Text("Complete your booking at"),
              subtitle: Text(""),
              tileColor: Theme.of(context).backgroundColor,
              trailing: Icon(Icons.arrow_forward),
            ),
          ),
        );
      },
    );
  }
}
