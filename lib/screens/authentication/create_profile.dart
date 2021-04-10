import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/authentication/login_screen.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/firebaseX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class CreateYourProfileScreen extends StatefulWidget {
  final Future<bool> Function()? shouldPop;

  const CreateYourProfileScreen({
    Key? key,
    this.shouldPop,
  }) : super(key: key);
  @override
  _CreateYourProfileScreenState createState() =>
      _CreateYourProfileScreenState();
}

class _CreateYourProfileScreenState extends State<CreateYourProfileScreen> {
  final _key = GlobalKey<FormState>();
  String _name = "";
  String _email = "";
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: WillPopScope(
          onWillPop: widget.shouldPop,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: !_loading
                  ? SingleChildScrollView(
                      child: Form(
                        key: _key,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Create your profile",
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Builder(
                              builder: (_) {
                                return Builder(
                                  builder: (_) {
                                    _name = UserX.i.user()?.name ?? "";
                                    return TextFormField(
                                      initialValue: _name,
                                      decoration: const InputDecoration(
                                          labelText: "What is your name?"),
                                      onChanged: (s) {
                                        _name = s;
                                      },
                                      validator: (s) {
                                        if ((s?.length ?? 0) > 4) {
                                          return null;
                                        }
                                        return "Enter your full name";
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Your real name is required for service providers to identify you.",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Builder(
                              builder: (_) {
                                return Builder(
                                  builder: (_) {
                                    _email = UserX.i.user()?.email ?? "";
                                    return TextFormField(
                                      initialValue: _email,
                                      decoration: const InputDecoration(
                                        labelText: "Email address",
                                      ),
                                      onChanged: (s) {
                                        _email = s;
                                      },
                                      validator: (s) {
                                        s ??= "";
                                        if (s.indexOf("@") <
                                            s.lastIndexOf(".")) {
                                          return null;
                                        }
                                        return "Enter a valid email address";
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Your email address will help you to recover your account and recieve updates on your bookings.",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            PrimaryButton(
                              "Update",
                              onPressed: () async {
                                if (_key.currentState?.validate() ?? false) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  await FirebaseX.i.updateProfile(
                                      displayName: _name,
                                      email: _email,
                                      onSuccess: () {
                                        //Helper.printLog("Success");
                                        BappNavigator.pop(context, null);
                                      },
                                      onFail: (e) {
                                        //Helper.printLog("Fail");
                                        setState(() {
                                          _loading = false;
                                        });
                                        switch (e.code) {
                                          case "invalid-email":
                                            {
                                              Flushbar(
                                                message: "The email is invalid",
                                                duration:
                                                    const Duration(seconds: 2),
                                              ).show(context);
                                              break;
                                            }
                                          case "same-email":
                                            {
                                              Flushbar(
                                                message: "Existing email",
                                                duration:
                                                    const Duration(seconds: 2),
                                              ).show(context);
                                              break;
                                            }
                                          case "email-already-in-use":
                                            {
                                              Flushbar(
                                                message:
                                                    "The email is already in use",
                                                duration:
                                                    const Duration(seconds: 2),
                                              ).show(context);
                                              break;
                                            }
                                          case "requires-recent-login":
                                            {
                                              Flushbar(
                                                message:
                                                    "Changing email requires recent login",
                                                duration:
                                                    const Duration(seconds: 4),
                                                mainButton: FlatButton(
                                                  onPressed: () async {
                                                    final loggedIn =
                                                        await BappNavigator
                                                            .push(context,
                                                                LoginScreen());
                                                    if (loggedIn) {
                                                      Flushbar(
                                                        message: "Logged in",
                                                        duration:
                                                            const Duration(
                                                                seconds: 2),
                                                      ).show(context);
                                                    }
                                                  },
                                                  child: Text(
                                                    "Login",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ).show(context);
                                              break;
                                            }
                                        }
                                      });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
