import 'dart:async';

import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/authentication/create_profile.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:the_country_number/the_country_number.dart';
import 'package:the_country_number_widgets/the_country_number_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../route_manager.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TheNumber _number;
  bool _canVerify = false, _canVerifyotp = false;
  bool _askOTP = false;
  List<Completer<String>> _otpFutureCompleters = [];

  @override
  void dispose() {
    _otpFutureCompleters = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CloudStore>(
      builder: (_, cloudStore, __) {
        return Scaffold(
          appBar: AppBar(
            leading: CloseButton(
              onPressed: () {
                BappNavigator.pop(context, null);
              },
            ),
          ),
          body: LayoutBuilder(
            builder: (_, c) {
              return Center(
                child: SingleChildScrollView(
                  child: !_askOTP
                      ? _getNumberWidget(cloudStore)
                      : _getOTPWidget(cloudStore),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _getNumberWidget(CloudStore cloudStore) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create an account or log in",
              style: Theme.of(context).textTheme.headline1,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Please enter a phone number where we can send you a verification code.",
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(
              height: 20,
            ),
            TheCountryNumberInput(
              TheCountryNumber()
                  .parseNumber(iso2Code: cloudStore.bappUser.address.iso2),
              onChanged: (tn){
                _number = tn;
                setState(() {
                  _canVerify = _number.isValidLength;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            PrimaryButton(
              "Verify",
              onPressed: _canVerify
                  ? () {
                      cloudStore.loginOrSignUpWithNumber(
                        number: _number,
                        onAskOTP: (bool b) async {
                          if (b) {
                            Flushbar(
                              message: "Please enter the correct OTP.",
                              duration: const Duration(seconds: 2),
                            ).show(context);
                          }

                          final t = Completer<String>();
                          _otpFutureCompleters.add(t);
                          setState(() {
                            _canVerifyotp = false;
                            _askOTP = true;
                            //print("Ask AGain");
                          });
                          return t.future;
                        },
                        onFail: (e) {
                          Flushbar(
                            message: "${e.code}",
                            duration: const Duration(seconds: 2),
                          ).show(context);
                        },
                        onVerified: () {
                          if (isNullOrEmpty(cloudStore.user.email) ||
                              isNullOrEmpty(cloudStore.user.displayName)) {
                            BappNavigator.pushReplacement(
                                context, CreateYourProfileScreen());
                          } else {
                            BappNavigator.pop(context, true);
                          }
                        },
                      );
                    }
                  : null,
            ),
            SizedBox(
              height: 20,
            ),
            RichText(
              text: TextSpan(
                  text: "By signing up you are agreeing to Our ",
                  style: Theme.of(context).textTheme.caption,
                  children: <TextSpan>[
                    TextSpan(
                      text: "terms ",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch(kTerms);
                        },
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .apply(color: Theme.of(context).primaryColor),
                    ),
                    TextSpan(
                      text: "and ",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    TextSpan(
                      text: "privacy policy.",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch(kPrivacy);
                        },
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .apply(color: Theme.of(context).primaryColor),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  String _otp = "";
  Widget _getOTPWidget(CloudStore cloudStore) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Observer(
          builder: (_) {
            return cloudStore.loadingForOTP
                ? CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/svg/review.svg",
                        width: 256,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Enter the 6 digit verification code we just sent you.",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Check your SMS inbox for a message.",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      PinCodeTextField(
                        autoFocus: true,
                        enablePinAutofill: true,
                        textStyle: Theme.of(context).textTheme.headline1,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        pinTheme: PinTheme(
                          activeColor: Theme.of(context).primaryColor,
                          selectedColor: Theme.of(context).primaryColor,
                          inactiveColor: Theme.of(context).primaryColor,
                          borderWidth: 3.0,
                        ),
                        appContext: context,
                        length: 6,
                        onChanged: (v) {
                          setState(
                            () {
                              if (v.length == 6) {
                                _otp = v;
                                _canVerifyotp = true;
                              } else {
                                _otp = "";
                                _canVerifyotp = false;
                              }
                            },
                          );
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      PrimaryButton(
                        "Verify",
                        onPressed: _canVerifyotp
                            ? () {
                                if (!_otpFutureCompleters.last.isCompleted) {
                                  _otpFutureCompleters.last.complete(_otp);
                                } else {
                                  print("COMPLETED");
                                }
                              }
                            : null,
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
