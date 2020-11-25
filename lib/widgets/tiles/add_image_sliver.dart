import 'package:bapp/widgets/removable_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class AddImageTileWidget extends StatefulWidget {
  final Function(Map<String, bool>) onImagesSelected;
  final Map<String, bool> existingImages;
  final String title;
  final String subTitle;
  final int maxImage;
  final EdgeInsets padding;

  AddImageTileWidget(
      {Key key,
      this.onImagesSelected,
      this.existingImages,
      this.title,
      this.subTitle,
      this.maxImage,
      this.padding})
      : super(key: key);

  @override
  _AddImageTileWidgetState createState() => _AddImageTileWidgetState();
}

class _AddImageTileWidgetState extends State<AddImageTileWidget> {
  final List<Asset> _pickedImages = [];
  final Map<String, bool> _existingImages = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        if (widget.existingImages != null) {
          _existingImages.addAll(widget.existingImages);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.title != null &&
        widget.subTitle != null &&
        widget.maxImage != null);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding:
              widget.padding ?? EdgeInsets.symmetric(horizontal: 16),
          title: Text(widget.title),
          subtitle: Text(widget.subTitle),
          trailing: Icon(
            Icons.add_a_photo_outlined,
            color: Theme.of(context).indicatorColor,
          ),
          onTap: () async {
            final picked = <Asset>[];
            final filtered = getFiltered();
            if (filtered.length == widget.maxImage) {
              Flushbar(
                message: "Max ${widget.maxImage} images",
                duration: const Duration(seconds: 2),
              ).show(context);
              return;
            }
            try {
              picked.addAll(await MultiImagePicker.pickImages(
                  maxImages: widget.maxImage - filtered.length));
            } catch (e) {
              Flushbar(
                message: "No images selected",
                duration: const Duration(seconds: 2),
              ).show(context);
              return;
            }
            await Future.forEach(picked, (element) async {
              final absPath =
                  await FlutterAbsolutePath.getAbsolutePath(element.identifier);
              //print(absPath);
              _existingImages["local" + absPath] = true;
            });
            setState(() {});
            widget.onImagesSelected(_existingImages);
          },
        ),
        SizedBox(
          height: 20,
        ),
        OrientationBuilder(
          builder: (_, o) {
            final cCount = o == Orientation.landscape ? 6 : 3;
            return LayoutBuilder(
              builder: (_, c) {
                final filtered = getFiltered();
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  child: filtered.length == 0
                      ? SizedBox(
                          height: 0,
                        )
                      : SizedBox(
                          width: c.maxWidth,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ...List.generate(filtered.length, (index) {
                                  return SizedBox(
                                    height: c.maxWidth / cCount,
                                    width: c.maxWidth / cCount,
                                    child: RemovableImageWidget(
                                      storageUrlOrPath: filtered[index],
                                      onRemove: () {
                                        setState(() {
                                          if (filtered[index]
                                              .startsWith("local")) {
                                            filtered.removeAt(index);
                                            _existingImages.clear();
                                            _existingImages.addAll(
                                                Map.fromEntries(filtered.map(
                                                    (e) => MapEntry(e, true))));
                                          } else {
                                            _existingImages[filtered[index]] =
                                                false;
                                          }
                                        });
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                );
              },
            );
          },
        )
      ],
    );
  }

  List<String> getFiltered() {
    final List<String> list = [];
    _existingImages.forEach((key, value) {
      if (value) {
        list.add(key);
      }
    });
    return list;
  }
}
