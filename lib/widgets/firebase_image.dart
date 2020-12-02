import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:bapp/config/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
  final _memoizer = AsyncMemoizer<Uint8List>();

  @override
  void initState() {
    if (!widget.storagePathOrURL.endsWith(".svg")) {
      _mem();
    }
    super.initState();
  }

  void _mem() {
    _memoizer.runOnce(() async {
      final file =
          await DefaultCacheManager().getFileFromCache(widget.storagePathOrURL);
      if (file != null) {
        return file.file.readAsBytes();
      } else if (widget.storagePathOrURL.startsWith("http")) {
        return (await DefaultCacheManager()
                .downloadFile(widget.storagePathOrURL))
            .file
            .readAsBytes();
      } else {
        final i = FirebaseStorage.instance;
        final data = await i
            .ref()
            .child(
              widget.storagePathOrURL,
            )
            .getData(1024 * 1024 * 2);
        final newFile =
            await DefaultCacheManager().putFile(widget.storagePathOrURL, data);
        return newFile.readAsBytes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, cons) {
        return widget.storagePathOrURL.endsWith("svg")
            ? widget.circular
                ? CircleAvatar(
                    backgroundImage: svg.Svg(kTemporaryPlaceHolderImage),
                  )
                : SvgPicture.asset(
                    widget.storagePathOrURL,
                    fit: BoxFit.contain,
                    width: widget.width ?? cons.maxWidth,
                    height: widget.height ?? cons.maxHeight,
                  )
            : FutureBuilder<Uint8List>(
                future: _memoizer.future,
                builder: (_, snap) {
                  if (snap.hasData) {
                    if (widget.circular) {
                      return SizedBox(
                        height: widget.height,
                        width: widget.width,
                        child: CircleAvatar(
                          backgroundImage: MemoryImage(snap.data),
                        ),
                      );
                    } else {
                      return Image.memory(
                        snap.data,
                        fit: widget.fit,
                        width: widget.width ?? cons.maxWidth,
                        height: widget.height ?? cons.maxHeight,
                      );
                    }
                  }
                  return SizedBox(
                    height: widget.height,
                    width: widget.width,
                    child: _getLoader(),
                  );
                },
              );
      },
    );
  }

  Widget _getLoader() {
    return Center(
      child: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          )),
    );
  }
}

class ListTileFirebaseImage extends StatelessWidget {
  final String storagePathOrURL;
  final bool circular;

  const ListTileFirebaseImage(
      {Key key, this.storagePathOrURL, this.circular = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RRFirebaseStorageImage(
      height: 48,
      width: 48,
      circular: circular,
      storagePathOrURL: storagePathOrURL,
    );
  }
}

class RRFirebaseStorageImage extends StatelessWidget {
  final String storagePathOrURL;
  final double width, height;
  final bool circular;

  const RRFirebaseStorageImage(
      {Key key,
      this.storagePathOrURL,
      this.width,
      this.height,
      this.circular = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: FirebaseStorageImage(
        width: width,
        height: height,
        circular: circular,
        storagePathOrURL: storagePathOrURL,
      ),
    );
  }
}
