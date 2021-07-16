import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/persistenceX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:get/get.dart';
import "package:provider/provider.dart";
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BranchChooserScreen extends StatelessWidget {
  final Partner partner;
  const BranchChooserScreen({
    Key? key,
    required this.partner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose your Branch"),
        centerTitle: false,
      ),
      body: TapToReFetch<Partner?>(
        fetcher: () => Partners.findOne(partner.id!),
        onLoadBuilder: (_) => LoadingWidget(),
        onErrorBuilder: (_, e, s) {
          bPrint(e);
          bPrint(s);
          return ErrorTile(message: "$e");
        },
        onSucessBuilder: (context, partner) {
          final businesses = partner?.businesses ?? [];
          if (businesses.isEmpty) {
            return Text("No businesses");
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: businesses.length,
              itemBuilder: (_, i) {
                return BusinessTileWidget(
                  withImage: true,
                  branch: businesses[i],
                  onTap: () async {
                    Get.back(
                      result: businesses[i],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
