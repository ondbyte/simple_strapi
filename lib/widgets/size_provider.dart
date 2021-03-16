import 'package:bapp/helpers/helper.dart';
import 'package:flutter/cupertino.dart';

///this widget provides the size of the already rendered child so we can render another above it using the size

class OnChildSizedWidget extends StatefulWidget {
  final Widget child;
  final Function(Size) onChildSize;

  const OnChildSizedWidget({Key key, this.onChildSize, this.child})
      : super(key: key);
  @override
  _OnChildSizedWidgetState createState() => _OnChildSizedWidgetState();
}

class _OnChildSizedWidgetState extends State<OnChildSizedWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        widget.onChildSize(context.size);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class RenderAfterChildWidget extends StatefulWidget {
  final Widget Function(Size) onChildRendered;
  final Widget child;

  const RenderAfterChildWidget({Key key, this.onChildRendered, this.child})
      : super(key: key);
  @override
  _RenderAfterChildWidgetState createState() => _RenderAfterChildWidgetState();
}

class _RenderAfterChildWidgetState extends State<RenderAfterChildWidget> {
  Widget _upperChild = const SizedBox();
  @override
  Widget build(BuildContext context) {
    return OnChildSizedWidget(
      child: Stack(
        children: [
          widget.child,
          _upperChild,
        ],
      ),
      onChildSize: (s) {
        setState(() {
          Helper.bPrint("setting upper child");
          _upperChild = widget.onChildRendered(s);
        });
      },
    );
  }
}
