import 'package:bapp/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CancellationConfirm {
  final bool confirm;
  final String reason;

  CancellationConfirm({this.confirm = false, this.reason = ""});
}

class CancellationConfirmDialog extends StatefulWidget {
  final String title, message;
  final bool needReason;

  const CancellationConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.needReason = false,
  }) : super(key: key);
  @override
  _CancellationConfirmDialogState createState() =>
      _CancellationConfirmDialogState();
}

class _CancellationConfirmDialogState extends State<CancellationConfirmDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: CancellationConfirm());
        return false;
      },
      child: AlertDialog(
        title: Text(widget.title),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.message),
              SizedBox(
                height: 20,
              ),
              if (widget.needReason)
                TextFormField(
                  decoration: InputDecoration(labelText: "Reason"),
                  validator: (s) {
                    if (s?.isEmpty ?? true) {
                      return "Enter a reason";
                    }
                    return null;
                  },
                )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!(_formKey.currentState?.validate() ?? false)) {
                return;
              }
              Get.back(
                result: CancellationConfirm(
                  confirm: true,
                  reason: widget.needReason ? "" : _controller.text,
                ),
              );
            },
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Get.back(
                result: CancellationConfirm(),
              );
            },
            child: Text("No"),
          ),
        ],
      ),
    );
  }
}
