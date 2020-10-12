import 'package:flutter/material.dart';

class SearchInsideBappScreen extends StatefulWidget {
  @override
  _SearchInsideBappScreenState createState() => _SearchInsideBappScreenState();
}

class _SearchInsideBappScreenState extends State<SearchInsideBappScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Card(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextField()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
