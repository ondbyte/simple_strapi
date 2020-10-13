import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/updates_store.dart';
import 'package:bapp/widgets/feedback_layer_widget.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import 'business_home.dart';
import 'customer_home.dart';

class Bapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<CloudStore>(
      store: Provider.of<CloudStore>(context),
      init: (cloudStore) async {
        await Provider.of<UpdatesStore>(context, listen: false).init(context);
        await Provider.of<BusinessStore>(context, listen: false).init(context);
      },
      builder: (_, cloudStore) {
        return Observer(
          builder: (_) {
            switch (cloudStore.userType) {
              case UserType.customer:
                return CustomerHome();
              case UserType.businessOwner:
                return BusinessHome();
              case UserType.businessStaff:
                return SizedBox();
              default:
                return Container(
                  color: Colors.red,
                );
            }
          },
        );
      },
    );
  }
}
