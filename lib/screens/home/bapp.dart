import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/updates_store.dart';
import 'package:bapp/widgets/feedback_layer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'customer_home.dart';

class Bapp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      initializer: () async {
        final authStore = Provider.of<AuthStore>(context, listen: false);
        await Provider.of<UpdatesStore>(context, listen: false).init(context);
        await Provider.of<BusinessStore>(context, listen: false).init(context);
      },
      child: Stack(
        children: [
          if("notbusiness"=="notbusiness")
            CustomerHome(),
        ],
      ),
    );
  }
}
