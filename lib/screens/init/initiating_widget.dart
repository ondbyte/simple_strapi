import 'package:flutter/widgets.dart';

///InitWidget helps to call a function after all the initializers has been returned
class InitWidget extends StatefulWidget {
  final Function initializer;
  final Widget child;
  final Function onInitComplete;

  const InitWidget({Key key, this.initializer,this.child,this.onInitComplete}) : super(key: key);

  @override
  _InitWidgetState createState() => _InitWidgetState();
}

class _InitWidgetState extends State<InitWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await widget.initializer();
      if(widget.onInitComplete!=null){
        widget.onInitComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.child!=null);
    return widget.child;
  }
}

