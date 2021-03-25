import 'package:bapp/widgets/removable_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class AddImageTileWidget extends StatefulWidget {
  final Function(Map<String, bool>)? onImagesSelected;
  final Map<String, bool> existingImages;
  final String title;
  final String subTitle;
  final int maxImage;
  final EdgeInsets? padding;

  AddImageTileWidget({
    Key? key,
    this.onImagesSelected,
    this.existingImages = const {},
    required this.title,
    required this.subTitle,
    required this.maxImage,
    this.padding,
  }) : super(key: key);

  @override
  _AddImageTileWidgetState createState() => _AddImageTileWidgetState();
}

class _AddImageTileWidgetState extends State<AddImageTileWidget> {
  final List<Asset> _pickedImages = [];
  final Removables _existingImages = Removables([], []);

  @override
  void initState() {
    _existingImages.nonRemovables.addAll(widget.existingImages.keys);
    super.initState();
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
            if (_existingImages.nonRemovables.length == widget.maxImage) {
              Flushbar(
                message: "Max ${widget.maxImage} images",
                duration: const Duration(seconds: 2),
              ).show(context);
              return;
            }
            try {
              picked.addAll(await MultiImagePicker.pickImages(
                  maxImages:
                      widget.maxImage - _existingImages.nonRemovables.length));
            } catch (e) {
              Flushbar(
                message: "No images selected",
                duration: const Duration(seconds: 2),
              ).show(context);
              return;
            }
            await Future.forEach<Asset>(picked, (element) async {
              final absPath =
                  await FlutterAbsolutePath.getAbsolutePath(element.identifier);
              //print(absPath);
              _existingImages.nonRemovables.add("local" + absPath);
            });
            setState(() {});
            widget.onImagesSelected?.call(_getFinal());
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
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  child: _existingImages.nonRemovables.length == 0
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
                                ...List.generate(
                                    _existingImages.nonRemovables.length,
                                    (index) {
                                  final empty = _existingImages.removables
                                      .contains(
                                          _existingImages.nonRemovables[index]);
                                  if (empty) {
                                    return SizedBox();
                                  }
                                  return SizedBox(
                                    height: c.maxWidth / cCount,
                                    width: c.maxWidth / cCount,
                                    child: RemovableImageWidget(
                                      key: Key(
                                        _existingImages.nonRemovables[index],
                                      ),
                                      storageUrlOrPath:
                                          _existingImages.nonRemovables[index],
                                      onRemove: () {
                                        setState(() {
                                          if (_existingImages
                                              .nonRemovables[index]
                                              .startsWith("local")) {
                                            _existingImages.nonRemovables
                                                .remove(_existingImages
                                                    .nonRemovables[index]);
                                          } else {
                                            _existingImages.removables.add(
                                                _existingImages
                                                    .nonRemovables[index]);
                                          }
                                          widget.onImagesSelected
                                              ?.call(_getFinal());
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

  Map<String, bool> _getFinal() {
    final m = <String, bool>{};
    _existingImages.removables.forEach((element) {
      _existingImages.nonRemovables.remove(element);
      m.addAll({element: false});
    });
    _existingImages.nonRemovables.forEach((element) {
      m.addAll({element: true});
    });
    return m;
  }
}

class Removables {
  final List<String> nonRemovables;
  final List<String> removables;

  Removables(this.nonRemovables, this.removables);
}
