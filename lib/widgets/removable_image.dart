import 'dart:typed_data';

import 'package:bapp/widgets/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class RemovableImageWidget extends StatelessWidget {
  final Asset asset;
  final Uint8List data;
  final String storageUrlOrPath;
  final BoxFit fit;
  final Function onRemove;
  final isThumbNail;
  const RemovableImageWidget(
      {Key key,
      this.asset,
      this.fit = BoxFit.cover,
      this.onRemove,
      this.isThumbNail = true,
      this.data,
      this.storageUrlOrPath = ""})
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
              child: Builder(
                builder: (_) {
                  if (storageUrlOrPath.isNotEmpty) {
                    if (storageUrlOrPath.startsWith("local")) {
                      return Image.asset(
                        storageUrlOrPath.replaceFirst("local", ""),
                        fit: fit,
                      );
                    }
                    return FirebaseStorageImage(
                        storagePathOrURL: storageUrlOrPath);
                  }
                  return FutureBuilder<ByteData>(
                    future: asset != null
                        ? asset.getByteData()
                        : data.buffer.asByteData(),
                    builder: (_, snap) {
                      return snap.hasData
                          ? Image.memory(
                              snap.data.buffer.asUint8List(),
                              fit: fit,
                            )
                          : Center(
                              child: Icon(Icons.image_sharp),
                            );
                    },
                  );
                },
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
