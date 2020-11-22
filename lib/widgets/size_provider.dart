import 'package:flutter/cupertino.dart';

///this widget provides the size of the already rendered child so we can render another above it using the size

class OnChildSizedWidget extends StatefulWidget {
  final Widget child;
  final Widget Function(Size) onChildSize;

  const OnChildSizedWidget({Key key, this.onChildSize, this.child})
      : super(key: key);
  @override
  _OnChildSizedWidgetState createState() => _OnChildSizedWidgetState();
}

class _OnChildSizedWidgetState extends State<OnChildSizedWidget> {
  Widget _upperChild = SizedBox();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _upperChild = widget.onChildSize(context.size);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [widget.child, _upperChild],
    );
  }
}
