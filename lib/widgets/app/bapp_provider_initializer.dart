

import 'package:bapp/config/constants.dart';
import 'package:bapp/stores/all_store.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/updates_store.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///class for initializing the provider
class BappProviderInitializerWidget extends StatefulWidget {
  final Widget child;

  const BappProviderInitializerWidget({Key key, this.child}) : super(key: key);
  @override
  _BappProviderInitializerWidgetState createState() => _BappProviderInitializerWidgetState();
}

class _BappProviderInitializerWidgetState extends State<BappProviderInitializerWidget> {
  @override
  Widget build(BuildContext context) {
    final allStore = AllStore();
    allStore.set<EventBus>(kBus);
    final cloudStore = CloudStore()..setAllStore(allStore);
    allStore.set<CloudStore>(cloudStore);
    final businessStore = BusinessStore()..setAllStore(allStore);
    allStore.set<BusinessStore>(businessStore);
    final flow = BookingFlow(allStore);
    allStore.set<BookingFlow>(flow);
    return MultiProvider(
      providers: [
        Provider<EventBus>(
          create: (_) => kBus,
        ),
        Provider<AllStore>(
          create: (_) => allStore,
        ),
        Provider<CloudStore>(
          create: (_) => cloudStore,
        ),
        Provider<UpdatesStore>(
          create: (_) => UpdatesStore(),
        ),
        Provider<BusinessStore>(
          create: (_) => businessStore,
        ),
        Provider<BookingFlow>(
          create: (_) => flow,
        ),
      ],
      builder: (context, w) {
        return widget.child;
      },
    );
  }
}