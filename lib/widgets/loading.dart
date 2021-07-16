import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CircularProgressIndicator(),
          ),
          if (message is String) Text("$message")
        ],
      ),
    );
  }
}

class PopResistLoadingScreen extends StatefulWidget {
  PopResistLoadingScreen({Key? key}) : super(key: key);

  @override
  _PopResistLoadingScreenState createState() => _PopResistLoadingScreenState();
}

class _PopResistLoadingScreenState extends State<PopResistLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: LoadingWidget(),
    );
  }
}
