import 'package:bapp/config/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;

class FirebaseStorageImage extends StatefulWidget {
  final String storagePathOrURL;
  final BoxFit fit;
  final double height;
  final double width;
  final bool circular;
  const FirebaseStorageImage({
    Key key,
    @required this.storagePathOrURL,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.circular = false,
  }) : super(key: key);

  @override
  _FirebaseStorageImageState createState() => _FirebaseStorageImageState();
}

class _FirebaseStorageImageState extends State<FirebaseStorageImage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_,cons) {
        return widget.storagePathOrURL.endsWith("svg")
            ? widget.circular
                ? CircleAvatar(
                    backgroundImage: svg.Svg(kTemporaryBusinessImage),
                  )
                : SvgPicture.asset(
                    widget.storagePathOrURL,
                    fit: BoxFit.contain,
                    width: widget.width??cons.maxWidth,
                    height: widget.height??cons.maxHeight,
                  )
            : FutureBuilder<String>(
                future: () async {
                  final i = FirebaseStorage.instance;
                  final s = await i
                      .ref()
                      .child(
                        widget.storagePathOrURL,
                      )
                      .getDownloadURL();
                  return s as String;
                }(),
                builder: (_, snap) {
                  if (snap.hasData) {
                    if (widget.circular) {
                      return CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          snap.data,
                        ),
                      );
                    } else {
                      return CachedNetworkImage(
                        imageUrl: snap.data,
                        fit: widget.fit,
                        width: widget.width??cons.maxWidth,
                        height: widget.height??cons.maxHeight,
                      );
                    }
                  }
                  if (widget.circular) {
                    return CircleAvatar(
                      backgroundImage: svg.Svg(kTemporaryBusinessImage),
                    );
                  }
                  return SvgPicture.asset(
                    kTemporaryBusinessImage,
                    fit: BoxFit.contain,
                    width: widget.width??cons.maxWidth,
                    height: widget.height??cons.maxHeight,
                  );
                },
              );
      },
    );
  }
}
