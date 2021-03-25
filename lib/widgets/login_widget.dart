import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/authentication/login_screen.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AskToLoginWidget extends StatelessWidget {
  final String loginReason, secondaryReason;

  const AskToLoginWidget(
      {Key? key, required this.loginReason, required this.secondaryReason})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: OrientationBuilder(
        builder: (_, o) {
          return SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/svg/login.svg",
                  height: o == Orientation.landscape ? 32 : 128,
                ),
                SizedBox(
                  height: 20,
                  width: 20,
                ),
                Text(
                  "$loginReason",
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(
                  height: 20,
                  width: 20,
                ),
                Text(
                  "$secondaryReason",
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                  width: 20,
                ),
                PrimaryButton(
                  "Sign In or Sign Up",
                  fullWidth: false,
                  onPressed: () {
                    BappNavigator.push(context, LoginScreen());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
