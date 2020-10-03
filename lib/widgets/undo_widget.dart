import 'package:bapp/classes/notification_update.dart';
import 'package:bapp/stores/feedback_store.dart';
import 'package:bapp/stores/updates_store.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UndoWidget extends StatelessWidget {
  final Key key;
  final Widget child;
  final TheFeedBack undoFeedBack;
  const UndoWidget({this.undoFeedBack, this.key, this.child,}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      child: child,
      onDismissed: (dir){
        Provider.of<FeedbackStore>(context,listen: false).ping(undoFeedBack);
      },
    );
  }
}
