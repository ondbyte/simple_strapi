import 'package:bapp/route_manager.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AskToLoginWidget extends StatelessWidget {
  final String loginReason, secondaryReason;

  const AskToLoginWidget({Key key, this.loginReason, this.secondaryReason})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/svg/login.svg",
            width: 128,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "$loginReason",
            style: Theme.of(context).textTheme.headline1,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "$secondaryReason",
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 20,
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushNamed(RouteManager.loginScreen);
            },
            color: Theme.of(context).primaryColor,
            child: Text(
              "Sign In or Sign Up",
              style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).primaryColorLight,),
            ),
          ),
        ],
      ),
    );
  }
}
