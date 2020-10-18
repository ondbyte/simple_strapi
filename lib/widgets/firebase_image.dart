import 'package:bapp/config/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class FirebaseStorageImage extends StatefulWidget {
  final String storagePathOrURL;
  final BoxFit fit;
  final double height;
  final double width;
  const FirebaseStorageImage(
      {Key key,
      @required this.storagePathOrURL,
      this.fit = BoxFit.cover,
      this.height,
      this.width})
      : super(key: key);

  @override
  _FirebaseStorageImageState createState() => _FirebaseStorageImageState();
}

class _FirebaseStorageImageState extends State<FirebaseStorageImage> {
  @override
  Widget build(BuildContext context) {
    return widget.storagePathOrURL.startsWith("http")
        ? CachedNetworkImage(
            imageUrl: widget.storagePathOrURL,
            fit: widget.fit,
            width: widget.width,
            height: widget.height,
          )
        : FutureBuilder<String>(
            future: () async {
              final i = FirebaseStorage.instance;
              final s =
                  await i.ref().child(widget.storagePathOrURL).getDownloadURL();
              return s as String;
            }(),
            builder: (_, snap) {
              if (snap.hasData) {
                return CachedNetworkImage(
                  imageUrl: snap.data,
                  fit: widget.fit,
                  width: widget.width,
                  height: widget.height,
                );
              }
              return CachedNetworkImage(
                imageUrl: kTemporaryBusinessImage,
                fit: widget.fit,
                width: widget.width,
                height: widget.height,
              );
            },
          );
  }
}
