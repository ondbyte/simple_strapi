import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequiredDialog extends StatelessWidget {
  final String message;
  const RequiredDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Required"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text("OK"),
        )
      ],
    );
  }
}
