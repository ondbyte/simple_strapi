import 'package:flutter/material.dart';

class ShowResultsScreen extends StatelessWidget {
  final dynamic showResultsFor;

  const ShowResultsScreen({Key? key, this.showResultsFor}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (_, snap) {
        return SizedBox();
      },
    );
  }
}
