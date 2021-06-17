import 'dart:async';

import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/authentication/create_profile.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/firebaseX.dart';
import 'package:bapp/super_strapi/my_strapi/localityX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:bapp/widgets/failed_strapi_response.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';
import 'package:the_country_number/the_country_number.dart';
import 'package:the_country_number_widgets/the_country_number_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TheNumber? _number;
  Rx<bool> _canVerify = false.obs, _canVerifyotp = false.obs;
  Rx<bool> _askOTP = false.obs, _loading = false.obs;
  List<Completer<String>>? _otpFutureCompleters = [];

  late ValueKey _getCountryKey;

  @override
  void initState() {
    super.initState();
    _getCountryKey = ValueKey(DateTime.now());
  }

  @override
  void dispose() {
    _otpFutureCompleters = null;
    super.dispose();
  }

  Future _popOnUser() async {
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      return UserX.i.userNotPresent;
    });
    BappNavigator.pop(
      context,
      true,
    );
  }

  final _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: () {
            BappNavigator.pop(context, null);
          },
        ),
      ),
      body: TapToReFetch<Country?>(
        onTap: () => _getCountryKey = ValueKey(DateTime.now()),
        fetcher: () {
          return LocalityX.i.getCountryFor(
            key: _getCountryKey,
            city: UserX.i.user()?.city ?? DefaultDataX.i.defaultData()?.city,
            locality: UserX.i.user()?.locality ??
                DefaultDataX.i.defaultData()!.locality,
          );
        },
        onLoadBuilder: (_) {
          return LoadingWidget();
        },
        onErrorBuilder: (_, e, s) {
          bPrint(e);
          bPrint(s);
          return ErrorTile(message: "Some error occured tap to refresh");
        },
        onSucessBuilder: (_, country) {
          if (country is! Country) {
            return FailedStrapiResponse(message: "Unable to get country");
          }
          return Center(
            child: SingleChildScrollView(
              child: Obx(
                () {
                  return !_askOTP()
                      ? _loading()
                          ? LoadingWidget()
                          : _getNumberWidget(country)
                      : _getOTPWidget();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getNumberWidget(Country c) {
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
              TheCountryNumber().parseNumber(
                iso2Code: c.iso2Code,
              ),
              onChanged: (tn) {
                _number = tn;
                _canVerify.value = _number?.isValidLength ?? false;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(
              () => PrimaryButton(
                "Verify",
                onPressed: _canVerify()
                    ? () {
                        if (_number is! TheNumber) {
                          return;
                        }
                        _loading(true);
                        FirebaseX.i.loginOrSignUpWithNumber(
                          onResendOTPPossible: () {},
                          number: _number as TheNumber,
                          onAskOTP: (bool b) async {
                            if (b) {
                              Flushbar(
                                message: "Please enter the correct OTP.",
                                duration: const Duration(seconds: 2),
                              ).show(context);
                            }

                            final t = Completer<String>();
                            _otpFutureCompleters?.add(t);

                            _canVerifyotp.value = false;
                            _askOTP.value = true;
                            _loading.value = false;
                            return t.future;
                          },
                          onFail: (e) {
                            Flushbar(
                              message: "${e.code}",
                              duration: const Duration(seconds: 2),
                            ).show(context);
                            _loading(false);
                          },
                          onVerified: () async {
                            if (FirebaseX.i.userPresent &&
                                (isNullOrEmpty(
                                        FirebaseX.i.firebaseUser?.email) ||
                                    isNullOrEmpty(
                                      FirebaseX.i.firebaseUser?.displayName,
                                    ))) {
                              await BappNavigator.pushReplacement(
                                context,
                                CreateYourProfileScreen(
                                  shouldPop: () async {
                                    return UserX.i.userPresent;
                                  },
                                ),
                              );
                              _popOnUser();
                            } else {
                              _popOnUser();
                            }
                          },
                        );
                      }
                    : null,
              ),
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
                          ?.apply(color: Theme.of(context).primaryColor),
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
                          ?.apply(color: Theme.of(context).primaryColor),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  String _otp = "";
  Widget _getOTPWidget() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Obx(
          () => !_askOTP()
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
                        if (v.length == 6) {
                          _otp = v;
                          _canVerifyotp.value = true;
                        } else {
                          _otp = "";
                          _canVerifyotp.value = false;
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Obx(
                      () => PrimaryButton(
                        "Verify",
                        onPressed: _canVerifyotp()
                            ? () {
                                if (!(_otpFutureCompleters?.last.isCompleted ??
                                    true)) {
                                  _otpFutureCompleters?.last.complete(_otp);
                                } else {
                                  print("COMPLETED");
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
