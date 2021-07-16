import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';

class EmailScreenResponse {
  final String email, password;

  EmailScreenResponse(this.email, this.password);
}

class EmailLoginScreen extends StatefulWidget {
  EmailLoginScreen({Key? key}) : super(key: key);

  @override
  _EmailLoginScreenState createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  String _email = "", _password = "";
  final _showPassword = Rx<bool>(false);
  final _formKey = GlobalKey<FormState>();
  final _disableSubmit = Rx<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      bottomNavigationBar: Obx(
        () => BottomPrimaryButton(
          label: "Login",
          onPressed: _disableSubmit()
              ? null
              : () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _disableSubmit(true);
                    final token = await FirebaseMessaging.instance.getToken();
                    try {
                      final user = await UserX.i
                          .loginWithEmailAndPassword(_email, _password, token);
                      Get.back(result: user);
                    } catch (e) {
                      await Flushbar(
                        message: "Unable to login, are the details correct?",
                        duration: const Duration(seconds: 2),
                      ).show(context);
                      _disableSubmit(false);
                    }
                  }
                },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: LayoutBuilder(builder: (context, cons) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svg/login.svg',
                  height: cons.maxHeight * 0.2,
                  width: cons.maxWidth * 0.2,
                ),
                SizedBox(
                  height: 32,
                ),
                TextFormField(
                  initialValue: _email,
                  onChanged: (s) {
                    _email = s;
                  },
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (s) =>
                      GetUtils.isEmail(s ?? "") ? null : "Enter a valid email",
                ),
                SizedBox(
                  height: 16,
                ),
                Obx(() => TextFormField(
                      obscureText: !_showPassword(),
                      initialValue: _password,
                      onChanged: (s) {
                        _password = s;
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffix: IconButton(
                          icon: Icon(_showPassword()
                              ? FeatherIcons.eyeOff
                              : FeatherIcons.eye),
                          onPressed: () {
                            _showPassword.value = !_showPassword.value;
                          },
                        ),
                      ),
                    )),
              ],
            ),
          );
        }),
      ),
    );
  }
}
