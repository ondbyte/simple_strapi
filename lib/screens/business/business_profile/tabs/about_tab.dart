import 'package:bapp/helpers/helper.dart';
import 'package:bapp/helpers/third_party_launcher.dart';
import 'package:bapp/widgets/padded_text.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessProfileAboutTab extends StatelessWidget {
  final Business business;
  BusinessProfileAboutTab({Key? key, required this.business}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final dayName = DateFormatters.dayName.format(DateTime.now()).toLowerCase();
    final dayTiming = business.dayTiming?.firstWhere(
      (e) =>
          EnumToString.convertToString(DayName.values[e.dayName!.index]) ==
          dayName,
    );
    final latlong = business.address?.coordinates;
    final timingsString = getAboutTabTimingString(dayTiming?.timings ?? []);
    final tagString = business.tag ?? "";
    final customerTypeEnum = business.customer_type;
    final typeString = business.type ?? "";
    final contactNumber = business.contactNumber ?? "";
    final about = business.partner?.about ?? business.about ?? "";

    return ListView(
      padding: EdgeInsets.only(top: 20),
      shrinkWrap: true,
      children: [
        // const SizedBox(
        // height: 20,
        // ),
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
          leading: const Icon(FeatherIcons.tag),
          dense: true,
          title: Text(
            EnumToString.convertToString(customerTypeEnum),
            style: Theme.of(context).textTheme.bodyText1?.apply(
                  color: Theme.of(context).primaryColor,
                ),
          ),
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
    );
  }
}
