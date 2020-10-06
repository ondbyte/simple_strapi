import 'package:bapp/stores/business_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThankYouForYourInterestScreen extends StatelessWidget {
  final BusinessCategory category;

  const ThankYouForYourInterestScreen({Key key, this.category})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thank you for your interest",
              style: Theme.of(context).textTheme.headline1,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Please send us below information and we will on-board you as quickly as possible",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Name of your business",
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Contact number",
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 0),
              trailing: Icon(Icons.arrow_forward_ios),
              title: Text(
                "Where is your business located",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              subtitle: Text(
                "Pick an Address",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Spacer(),
            MaterialButton(
              onPressed: () {},
              child: Row(
                children: [
                  Text("Submit"),
                  Spacer(),
                  Icon(Icons.arrow_forward),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
