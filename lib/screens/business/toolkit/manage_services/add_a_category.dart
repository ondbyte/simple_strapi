import 'package:flutter/material.dart';

class BusinessAddServiceCategoryScreen extends StatefulWidget {
  @override
  _BusinessAddServiceCategoryScreenState createState() => _BusinessAddServiceCategoryScreenState();
}

class _BusinessAddServiceCategoryScreenState extends State<BusinessAddServiceCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Add category"),
      ),
      body: CustomScrollView(
        slivers: [

        ],
      ),
    );
  }
}
