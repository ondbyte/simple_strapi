import 'package:flutter/widgets.dart';

///InitWidget helps to call a function after all the initializers has been returned
class InitWidget extends StatefulWidget {
  final Widget? showWhileInit;
  final Function initializer;
  final Widget child;
  final Function? onInitComplete;

  const InitWidget({
    Key? key,
    required this.initializer,
    required this.child,
    this.onInitComplete,
    this.showWhileInit,
  }) : super(key: key);

  @override
  _InitWidgetState createState() => _InitWidgetState();
}

class _InitWidgetState extends State<InitWidget> {
  var _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      await widget.initializer();
      setState(() {
        _done = true;
      });
      widget.onInitComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _done ? widget.child : (widget.showWhileInit ?? widget.child);
  }
}
