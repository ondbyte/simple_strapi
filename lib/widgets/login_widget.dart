import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginWidget extends StatelessWidget {
  final String loginReason,secondaryReason;

  const LoginWidget({Key key, this.loginReason, this.secondaryReason}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/svg/login.svg",width: 128,),
          SizedBox(height: 20,),
          Text("$loginReason",style: Theme.of(context).textTheme.headline1,),
          SizedBox(height: 20,),
          Text("$secondaryReason",style: Theme.of(context).textTheme.bodyText1,textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}

