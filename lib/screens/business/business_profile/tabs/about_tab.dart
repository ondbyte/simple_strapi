import 'package:bapp/helpers/third_party_launcher.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:bapp/widgets/padded_text.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessProfileAboutTab extends StatelessWidget {
  final Business business;
  BusinessProfileAboutTab({required this.business});
  @override
  Widget build(BuildContext context) {
    final latlong = business.address?.coordinates;
    final timingsString = "no timings string, inform yadu";
    final tagString = "no tagString string, inform yadu";
    final typeString = "no typeString string, inform yadu";
    final contactNumber = business.contactNumber ?? "";
    final about = business.partner?.about ?? business.about ?? "";

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
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            leading: const Icon(FeatherIcons.clock),
            dense: true,
            title: Text(
              timingsString,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(FeatherIcons.info),
            dense: true,
            title: Text(
              tagString,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(FeatherIcons.info),
            dense: true,
            title: Text(
              typeString,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(FeatherIcons.phone),
            dense: true,
            title: Text(
              contactNumber,
              style: Theme.of(context).textTheme.bodyText1?.apply(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            onTap: () {
              LaunchApp.phone(contactNumber);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(FeatherIcons.mapPin),
            dense: true,
            title: Text(
              "Get Directions",
              style: Theme.of(context).textTheme.bodyText1?.apply(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            onTap: () async {
              await LaunchApp.map(
                  latlong?.latitude ?? 0, latlong?.longitude ?? 0);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          PaddedText(
            "About " + (business.name ?? ""),
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(
            height: 20,
          ),
          PaddedText(
            about,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
