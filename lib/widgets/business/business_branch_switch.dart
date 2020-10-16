import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class BusinessBranchSwitchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessStore>(
      builder: (_, businessStore, __) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              RouteManager.businessBranchChooserScreen,
            );
          },
          child: Row(
            children: [
              Observer(
                builder: (_) {
                  return Text(
                    businessStore.business.selectedBranch.value.address.value
                        .split("\n")
                        .first,
                    style: Theme.of(context).textTheme.subtitle1,
                  );
                },
              ),
              SizedBox(
                width: 4,
              ),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        );
      },
    );
  }
}
