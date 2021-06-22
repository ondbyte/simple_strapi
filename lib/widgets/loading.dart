import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
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
