import 'dart:typed_data';

import 'package:flutter/material.dart';

class RemovableImageWidget extends StatelessWidget {
  final Uint8List data;
  final BoxFit fit;
  final Function onRemove;
  const RemovableImageWidget(
      {Key key, this.data, this.fit = BoxFit.cover, this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox.expand(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                data,
                fit: fit,
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.remove_circle,
            color: Theme.of(context).errorColor,
          ),
          onPressed: onRemove,
        )
      ],
    );
  }
}
