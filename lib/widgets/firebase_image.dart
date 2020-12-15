import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
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
  final Widget ifEmpty;

  const FirebaseStorageImage(
      {Key key,
      @required this.storagePathOrURL,
      this.fit = BoxFit.cover,
      this.height,
      this.width,
      this.ifEmpty})
      : super(key: key);

  @override
  _FirebaseStorageImageState createState() => _FirebaseStorageImageState();
}

class _FirebaseStorageImageState extends State<FirebaseStorageImage> {
  final _memoizer = AsyncMemoizer<Uint8List>();

  @override
  void initState() {
    if (!isNullOrEmpty(widget.storagePathOrURL)) {
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
    assert(!isNullOrEmpty(widget.storagePathOrURL)||(isNullOrEmpty(widget.storagePathOrURL) && widget.ifEmpty != null),
        "ifEmpty widget cannot be null if the URL is null");
    return LayoutBuilder(
      builder: (_, cons) {
        if (isNullOrEmpty(widget.storagePathOrURL)) {
          return widget.ifEmpty;
        }
        return FutureBuilder<Uint8List>(
          future: _memoizer.future,
          builder: (_, snap) {
            if (snap.hasData) {
              return Image.memory(
                snap.data,
                fit: widget.fit??BoxFit.cover,
                width: widget.width ?? cons.maxWidth,
                height: widget.height ?? cons.maxHeight,
              );
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
        ),
      ),
    );
  }
}

class ListTileFirebaseImage extends StatelessWidget {
  final String storagePathOrURL;
  final Widget ifEmpty;

  const ListTileFirebaseImage(
      {Key key, this.storagePathOrURL, this.ifEmpty})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RRFirebaseStorageImage(
      height: 48,
      width: 48,
      storagePathOrURL: storagePathOrURL,
      ifEmpty: ifEmpty,
    );
  }
}

class RRFirebaseStorageImage extends StatelessWidget {
  final String storagePathOrURL;
  final double width, height;
  final BoxFit fit;
  final Widget ifEmpty;

  const RRFirebaseStorageImage({
    Key key,
    this.storagePathOrURL,
    this.width,
    this.height,
    this.fit,
    this.ifEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: FirebaseStorageImage(
        width: width,
        height: height,
        storagePathOrURL: storagePathOrURL,
        fit: fit,
        ifEmpty: ifEmpty,
      ),
    );
  }
}

class Initial extends StatelessWidget {
  final String forName;

  const Initial({Key key, this.forName}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: CardsColor.next(),
      child: Text(
        forName?.substring(0,2),
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
