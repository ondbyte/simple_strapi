import 'package:bapp/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

var kLoading = Observable(false);

class LoadingStackWidget extends StatefulWidget {
  final Widget child;

  const LoadingStackWidget({Key key, this.child}) : super(key: key);

  @override
  _LoadingStackWidgetState createState() => _LoadingStackWidgetState();
}

class _LoadingStackWidgetState extends State<LoadingStackWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Observer(
          builder: (_) {
            return kLoading.value
                ? SizedBox(
                    child: Container(
                      color: Theme.of(context).backgroundColor,
                      child: LoadingWidget(),
                    ),
                  )
                : SizedBox();
          },
        )
      ],
    );
  }
}
