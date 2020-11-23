import 'dart:convert';

import 'package:bapp/helpers/third_party_launcher.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/widgets/padded_text.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bapp/helpers/extensions.dart';

class BusinessProfileAboutTab extends StatelessWidget {
  const BusinessProfileAboutTab();
  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<BookingFlow>(context);
    final latlong = flow.branch.latlong.value;
    final timingsString = flow.branch.getOpenTodayString();
    final tagString = flow.branch.tag.value;

    return SingleChildScrollView(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          PaddedText(
            "Important information",
            style: Theme.of(context).textTheme.headline1,
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(FeatherIcons.clock),
            title: Text(
              timingsString,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(FeatherIcons.clock),
            title: Text(
              tagString,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(FeatherIcons.mapPin),
            title: Text(
              "Get Directions",
              style: Theme.of(context).textTheme.subtitle1.apply(
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () async {
              await LaunchApp.map(latlong.latitude, latlong.longitude);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          PaddedText(
            "About "+flow.branch.name.value,
            style: Theme.of(context).textTheme.headline1,
          ),
          const SizedBox(
            height: 20,
          ),
          PaddedText(
            "About "+flow.branch.description.value,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
