import 'package:flutter/material.dart';

class PaddedText extends StatelessWidget {
  final EdgeInsets? padding;
  final TextStyle? style;
  final String data;
  const PaddedText(this.data, {Key? key, this.padding, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        "$data",
        style: style,
      ),
    );
  }
}
