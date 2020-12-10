import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../../helpers/helper.dart';

class BusinessBranchSwitchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<BusinessStore, CloudStore>(
      builder: (_, businessStore, cloudStore, __) {
        return GestureDetector(
          onTap: _branchChangeAllowed(cloudStore)
              ? () {
                  Navigator.of(context).pushNamed(
                    RouteManager.businessBranchChooserScreen,
                  );
                }
              : null,
          child: Row(
            children: [
              Observer(
                builder: (_) {
                  final text = businessStore
                      .business?.selectedBranch?.value?.address?.value;
                  return Text(
                    isNullOrEmpty(text)
                        ? "Select a branch"
                        : text.split(", ").first,
                    style: Theme.of(context).textTheme.subtitle1,
                  );
                },
              ),
              SizedBox(
                width: 4,
              ),
              if (_branchChangeAllowed(cloudStore))
                Icon(Icons.keyboard_arrow_down),
            ],
          ),
        );
      },
    );
  }

  bool _branchChangeAllowed(CloudStore cloudStore) {
    return cloudStore.bappUser.userType.value == UserType.businessManager ||
        cloudStore.bappUser.userType.value == UserType.businessOwner;
  }
}
