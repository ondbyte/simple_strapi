import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequiredDialog extends StatelessWidget {
  final String message;
  const RequiredDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Required",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Text("$message"),
              OutlinedButton(
                onPressed: Get.back,
                child: Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }
}
