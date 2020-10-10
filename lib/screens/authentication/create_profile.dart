import 'package:bapp/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateYourProfileScreen extends StatefulWidget {
  @override
  _CreateYourProfileScreenState createState() =>
      _CreateYourProfileScreenState();
}

class _CreateYourProfileScreenState extends State<CreateYourProfileScreen> {
  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _key,
          child: Column(
            children: [
              Text(
                "Create your profile",
                style: Theme.of(context).textTheme.headline1,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "What is your name?"),
                validator: (s){
                  if(s.length>4){
                    return null;
                  }
                  return "Enter your full name";
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
              TextFormField(
                decoration: InputDecoration(labelText: "Email address"),
                validator: (s){
                  if(s.indexOf("@")<s.lastIndexOf(".")){
                    return null;
                  }
                  return "Enter a valid email address";
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
              PrimaryButton("Let\'s Get Started", onPressed: (){
                if(_key.currentState.validate()){
                  /*Provider.of<AuthStore>(context).updateProfile(
                      userName:
                  )*/
                }
              },),
            ],
          ),
        ),
      ),
    );
  }
}
