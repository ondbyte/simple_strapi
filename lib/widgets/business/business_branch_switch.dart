import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/business/branch_chooser.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/persistenceX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

import '../../helpers/helper.dart';

class BusinessBranchSwitchWidget extends StatelessWidget {
  final Partner partner;
  final Business? business;
  const BusinessBranchSwitchWidget({
    Key? key,
    required this.business,
    required this.partner,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = UserX.i.user();
    if (user is! User) {
      return SizedBox();
    }
    return GestureDetector(
      onTap: () async {
        final picked = await BappNavigator.push(
          context,
          BranchChooserScreen(
            partner: partner,
          ),
        );
        if (picked is Business) {
          final updated =
              await Users.update(user.copyWIth(pickedBusiness: picked));
          UserX.i.user(updated);
        }
      },
      child: Row(
        children: [
          Builder(
            builder: (
              _,
            ) {
              if (business is Business) {
                return Text(
                  (business?.address?.locality?.name ?? "no address"),
                  style: Theme.of(context).textTheme.subtitle1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }
              return Text(
                "Select a branch",
                style: Theme.of(context).textTheme.subtitle1,
              );
            },
          ),
          SizedBox(
            width: 4,
          ),
          if (_branchChangeAllowed())
            Icon(
              Icons.keyboard_arrow_down,
            ),
        ],
      ),
    );
    ;
  }

  bool _branchChangeAllowed() {
    return true;
  }
}
