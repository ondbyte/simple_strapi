import 'package:bapp/stores/feedback_store.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class FeedBackLayerWidget extends StatefulWidget {

  @override
  _FeedBackLayerWidgetState createState() => _FeedBackLayerWidgetState();
}

class _FeedBackLayerWidgetState extends State<FeedBackLayerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      alignment: Alignment.bottomCenter,
      child: StoreProvider<FeedbackStore>(
        store: context.watch<FeedbackStore>(),
        init: (feedbackStore) async {
          await feedbackStore.init();
        },
        builder: (context,feedbackStore){
          return Observer(builder: (context){
            return feedbackStore.message;
          });
        },
      ),
    );
  }
}

class FeedbackWidget extends StatelessWidget {
  final Widget child;

  const FeedbackWidget({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.all(16),
        color: Theme.of(context).primaryColor,
        child: DefaultTextStyle(
          style: TextStyle(color: Theme.of(context).primaryColorLight),
          child: child,
        ),
      ),
    );
  }
}

