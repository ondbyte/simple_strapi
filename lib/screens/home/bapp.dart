import 'package:bapp/FCM.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/updates_store.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import 'business_home.dart';
import 'customer_home.dart';

class Bapp extends StatefulWidget {
  @override
  _BappState createState() => _BappState();
}

class _BappState extends State<Bapp> {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<CloudStore>(
      store: Provider.of<CloudStore>(context),
      init: (cloudStore) async {
        await Provider.of<UpdatesStore>(context, listen: false).init(context);
        //await Provider.of<BusinessStore>(context, listen: false).init(context);
        //Helper.printLog("setting up message layer");
        BappFCM().listenForBappMessages(
          (bappMessage) {
            //Helper.printLog("bappMessage");
            //print(bappMessage.toMap());
            setState(
              () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) {
                    return BappFCMMesssageLayerWidget(
                      latestMessage: bappMessage,
                    );
                  },
                );
              },
            );
          },
        );
      },
      builder: (_, cloudStore) {
        return Stack(
          children: [
            Observer(
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
            ),
          ],
        );
      },
    );
  }
}

class BappFCMMesssageLayerWidget extends StatefulWidget {
  final BappFCMMessage latestMessage;

  const BappFCMMesssageLayerWidget({Key key, this.latestMessage})
      : super(key: key);
  @override
  _BappFCMMesssageLayerWidgetState createState() =>
      _BappFCMMesssageLayerWidgetState();
}

class _BappFCMMesssageLayerWidgetState
    extends State<BappFCMMesssageLayerWidget> {
  BappFCMMessage _latestMessage;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _latestMessage = widget.latestMessage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_latestMessage == null) {
      return SizedBox();
    }
    return AlertDialog(
      title: Text(_latestMessage.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_latestMessage.body),
          SizedBox(
            height: 20,
          ),
          _buttonize(_latestMessage),
          _cancelButtonize(_latestMessage),
        ],
      ),
    );
  }

  _buttonize(BappFCMMessage message) {
    if (message.type == BappFCMMessageType.staffAuthorizationAsk) {
      return PrimaryButton(
        "Acknowledge",
        onPressed: () {
          Provider.of<CloudStore>(context, listen: false)
              .giveAuthorizationForStaffing(message, authorized: true);
          _latestMessage = null;
          Navigator.pop(context, true);
        },
      );
    }
  }

  _cancelButtonize(BappFCMMessage message) {
    if (message.type == BappFCMMessageType.staffAuthorizationAsk) {
      return FlatButton(
        child: Text("Not interested"),
        onPressed: () {
          Provider.of<CloudStore>(context, listen: false)
              .giveAuthorizationForStaffing(message);
          _latestMessage = null;
          Navigator.pop(context, false);
        },
      );
    }
  }
}
