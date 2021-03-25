import 'package:bapp/classes/firebase_structures/bapp_fcm_message.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/fcm.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'business_home.dart';
import 'customer_home.dart';

class Bapp extends StatefulWidget {
  @override
  _BappState createState() => _BappState();
}

class _BappState extends State<Bapp> {
  @override
  Widget build(BuildContext context) {
    return InitWidget(
      initializer: () async {},
      child: Stack(
        children: [
          Observer(
            builder: (_) {
              final role = EnumToString.fromString(
                UserRole.values,
                UserX.i.user()?.role?.name ?? "",
              );
              switch (role) {
                case UserRole.customer:
                case UserRole.public:
                  return CustomerHome();
                case UserRole.partner:
                case UserRole.manager:
                case UserRole.facilitator:
                case UserRole.staff:
                  return BusinessHome(
                    forRole: role,
                  );
                default:
                  return Container(
                    color: Colors.red,
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}

class BappFCMMesssageLayerWidget extends StatefulWidget {
  final BappFCMMessage? latestMessage;

  const BappFCMMesssageLayerWidget({Key? key, this.latestMessage})
      : super(key: key);
  @override
  _BappFCMMesssageLayerWidgetState createState() =>
      _BappFCMMesssageLayerWidgetState();
}

class _BappFCMMesssageLayerWidgetState
    extends State<BappFCMMesssageLayerWidget> {
  BappFCMMessage? _latestMessage;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      BappFCM().listenForBappMessages(
        (bappMessage) {
          setState(
            () async {
              showDialog(
                context: context,
                builder: (_) {
                  if (bappMessage == null) {
                    return SizedBox();
                  }
                  return AlertDialog(
                    title: Text("inform yadu"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("inform yadu"),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_latestMessage == null) {
      return SizedBox();
    }
    return AlertDialog(
      title: Text("inform yadu"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("inform yadu"),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
