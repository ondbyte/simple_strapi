import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: WillPopScope(
          onWillPop: () async {
            _key.currentState.validate();
            final user = FirebaseAuth.instance.currentUser;
            if (isNullOrEmpty(user.displayName) || isNullOrEmpty(user.email)) {
              return false;
            }
            return true;
          },
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
                            Consumer<CloudStore>(
                              builder: (_, cloudStore, __) {
                                return Observer(
                                  builder: (_) {
                                    _name = cloudStore.user.displayName;
                                    return TextFormField(
                                      initialValue: _name,
                                      decoration: const InputDecoration(
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
                            Consumer<CloudStore>(
                              builder: (_, cloudStore, __) {
                                return Observer(
                                  builder: (_) {
                                    _email = cloudStore.user.email;
                                    return TextFormField(
                                      initialValue: _email,
                                      decoration: const InputDecoration(
                                          labelText: "Email address"),
                                      onChanged: (s) {
                                        _email = s;
                                      },
                                      validator: (s) {
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
                              onPressed: () {
                                if (_key.currentState.validate()) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  Provider.of<CloudStore>(context,
                                          listen: false)
                                      .updateProfile(
                                          displayName: _name,
                                          email: _email,
                                          onSuccess: () {
                                            //Helper.printLog("Success");
                                            Navigator.of(context).pop();
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
                                                    message:
                                                        "The email is invalid",
                                                    duration: const Duration(
                                                        seconds: 2),
                                                  ).show(context);
                                                  break;
                                                }
                                              case "same-email":
                                                {
                                                  Flushbar(
                                                    message: "Existing email",
                                                    duration: const Duration(
                                                        seconds: 2),
                                                  ).show(context);
                                                  break;
                                                }
                                              case "email-already-in-use":
                                                {
                                                  Flushbar(
                                                    message:
                                                        "The email is already in use",
                                                    duration: const Duration(
                                                        seconds: 2),
                                                  ).show(context);
                                                  break;
                                                }
                                              case "requires-recent-login":
                                                {
                                                  Flushbar(
                                                    message:
                                                        "Changing email requires recent login",
                                                    duration: const Duration(
                                                        seconds: 4),
                                                    mainButton: FlatButton(
                                                      onPressed: () async {
                                                        final loggedIn =
                                                            await Navigator.of(
                                                                    context)
                                                                .pushNamed(
                                                          RouteManager
                                                              .loginScreen,
                                                        );
                                                        if (loggedIn) {
                                                          Flushbar(
                                                            message:
                                                                "Logged in",
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
