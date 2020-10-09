import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class ContextualMessageScreen extends StatefulWidget {
final  Function init;

  const ContextualMessageScreen({Key key, this.init}) : super(key: key);
  @override
  _ContextualMessageScreenState createState() => _ContextualMessageScreenState();
}

class _ContextualMessageScreenState extends State<ContextualMessageScreen> {
  bool loading = true;
  @override
  Widget build(BuildContext context) {
    return InitWidget(
      initializer: widget.init,
      onInitComplete: (){
        setState(() {
          loading = false;
        });
      },
      child: loading? LoadingWidget():
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/svg/messages.svg",width: 256,),
            SizedBox(height: 20,),
            Text("Thank you, We\'ll reach you out soon.."),
            SizedBox(height: 20,),
            FlatButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: Text("Back to Home"))
          ],
        )
      ),
    );
  }
}
