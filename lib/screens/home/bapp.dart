import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/fcm.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/loading.dart';
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
        await Provider.of<BookingFlow>(context, listen: false)
          ..init()
          ..getMyBookings();
      },
      builder: (_, cloudStore) {
        return Stack(
          children: [
            Observer(
              builder: (_) {
                if (cloudStore.bappUser == null) {
                  return Material(
                    child: LoadingWidget(),
                  );
                }
                switch (cloudStore.bappUser.userType.value) {
                  case UserType.customer:
                    return CustomerHome();
                  case UserType.businessOwner:
                    return BusinessHome(
                      forRole: UserType.businessOwner,
                    );
                  case UserType.businessStaff:
                    return BusinessHome(
                      forRole: UserType.businessStaff,
                    );
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
                    title: Text(bappMessage.title),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(bappMessage.body),
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
      title: Text(_latestMessage.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_latestMessage.body),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
