import 'package:bapp/stores/feedback_store.dart';
import 'package:bapp/stores/themestore.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:flushbar/flushbar.dart';
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
        builder: (context, feedbackStore) {
          return Observer(builder: (context) {
            if (feedbackStore.customWidget != null) {
              return feedbackStore.customWidget;
            }
            if (feedbackStore.feedBack != null) {
              return Flushbar(
                onStatusChanged: (status){
                  if(status==FlushbarStatus.DISMISSED){
                    if(feedbackStore.feedBack.doOnOkay!=null){
                      feedbackStore.feedBack.doOnOkay(feedbackStore.feedBack.variable);
                    }
                  }
                },
                backgroundColor:
                    feedbackStore.feedBack.type == TheFeedBackType.error
                        ? Theme.of(context).errorColor
                        : Theme.of(context).primaryColor,
                message: feedbackStore.feedBack.message,
                mainButton: feedbackStore.feedBack.doOnOkay != null
                    ? FlatButton(
                        onPressed: (){
                          if(feedbackStore.feedBack.doOnUndo!=null){
                            feedbackStore.feedBack.doOnUndo(feedbackStore.feedBack.variable);
                          } else {
                            feedbackStore.feedBack.doOnOkay(feedbackStore.feedBack.variable);
                          }
                        },
                        child: Text(
                          feedbackStore.feedBack.buttonLabel,
                        ),
                      )
                    : null,
              );
            }
            return SizedBox();
          });
        },
      ),
    );
  }
}
