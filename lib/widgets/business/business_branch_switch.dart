import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/business/branch_chooser.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../../helpers/helper.dart';

class BusinessBranchSwitchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (_) {
        return GestureDetector(
          child: Row(
            children: [
              FutureBuilder(
                future: DefaultDataX.i.getValue("selectedBarnch"),
                builder: (_, snap) {
                  final data = snap.data;
                  if (snap.connectionState == ConnectionState.done) {
                    if (data is String) {
                      return Text(
                        data,
                        style: Theme.of(context).textTheme.subtitle1,
                      );
                    }
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
              if (_branchChangeAllowed()) Icon(Icons.keyboard_arrow_down),
            ],
          ),
        );
      },
    );
  }

  bool _branchChangeAllowed() {
    return true;
  }
}
