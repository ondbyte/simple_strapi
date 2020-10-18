import 'package:bapp/stores/business_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusinessAddABranchScreen extends StatefulWidget {
  BusinessAddABranchScreen({Key key}) : super(key: key);

  @override
  _BusinessAddABranchScreenState createState() =>
      _BusinessAddABranchScreenState();
}

class _BusinessAddABranchScreenState extends State<BusinessAddABranchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "What is the name of your branch?",
              style: Theme.of(context).textTheme.headline1,
            ),
            SizedBox(
              height: 20,
            ),
            Consumer<BusinessStore>(
              builder: (_, businessStore, __) {
                return TextFormField(
                  initialValue: businessStore.business.businessName.value,
                  style: Theme.of(context).textTheme.headline3,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
