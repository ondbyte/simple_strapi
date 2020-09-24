import 'package:flutter/widgets.dart';

///InitWidget helps to call a function after all the initializers has been returned
class InitWidget extends StatefulWidget {
  final List<Function> initializers;
  final Widget child;
  final Function onInitComplete;

  const InitWidget({Key key, this.initializers,this.child,this.onInitComplete}) : super(key: key);

  @override
  _InitWidgetState createState() => _InitWidgetState();
}

class _InitWidgetState extends State<InitWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      for (var fn in widget.initializers){
        await fn();
      }
      widget.onInitComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.child!=null);
    return widget.child;
  }
}

