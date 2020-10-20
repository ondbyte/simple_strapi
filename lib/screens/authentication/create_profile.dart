import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class CreateYourProfileScreen extends StatefulWidget {
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
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: !_loading
              ? Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Create your profile",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Consumer<AuthStore>(
                        builder: (_, authStore, __) {
                          return Observer(
                            builder: (_) {
                              return TextFormField(
                                initialValue: authStore.user.displayName,
                                decoration: InputDecoration(
                                    labelText: "What is your name?"),
                                onChanged: (s) {
                                  _name = s;
                                },
                                validator: (s) {
                                  if (s.length > 4) {
                                    return null;
                                  }
                                  return "Enter your full name";
                                },
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Your real name is required for service providers to identify you.",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Consumer<AuthStore>(
                        builder: (_, authStore, __) {
                          return Observer(
                            builder: (_) {
                              return TextFormField(
                                initialValue: authStore.user.email,
                                decoration:
                                    InputDecoration(labelText: "Email address"),
                                onChanged: (s) {
                                  _email = s;
                                },
                                validator: (s) {
                                  if (s.indexOf("@") < s.lastIndexOf(".")) {
                                    return null;
                                  }
                                  return "Enter a valid email address";
                                },
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Your email address will help you to recover your account and recieve updates on your bookings.",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      PrimaryButton(
                        "Let\'s Get Started",
                        onPressed: () {
                          if (_key.currentState.validate()) {
                            setState(() {
                              _loading = true;
                            });
                            Provider.of<AuthStore>(context, listen: false)
                                .updateProfile(
                                    displayName: _name,
                                    email: _email,
                                    onSuccess: () {
                                      Navigator.of(context).pop();
                                    },
                                    onFail: (e) {
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
                                            Navigator.of(context)
                                                .pushReplacementNamed(
                                                    RouteManager.loginScreen);
                                            break;
                                          }
                                      }
                                    });
                          }
                        },
                      ),
                    ],
                  ),
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
