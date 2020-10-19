import 'dart:typed_data';

import 'package:bapp/widgets/removable_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:thephonenumber/data.dart';

class AddImageTileWidget extends StatefulWidget {
  final Function(List<Uint8List>) onImagesSelected;

  AddImageTileWidget({Key key, this.onImagesSelected}) : super(key: key);

  @override
  _AddImageTileWidgetState createState() => _AddImageTileWidgetState();
}

class _AddImageTileWidgetState extends State<AddImageTileWidget> {
  final List<Uint8List> imageDatas = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text("Photos"),
          subtitle: Text("You can add upto 3 photos now"),
          trailing: Icon(
            Icons.add_a_photo_outlined,
            color: Theme.of(context).primaryColorDark,
          ),
          onTap: () async {
            final picked = <Asset>[];
            if (imageDatas.length == 3) {
              Flushbar(
                message: "Max 3 images",
                duration: const Duration(seconds: 2),
              ).show(context);
              return;
            }
            try {
              picked.addAll(await MultiImagePicker.pickImages(
                  maxImages: 3 - imageDatas.length));
            } catch (e) {
              Flushbar(
                message: "No images selected",
                duration: const Duration(seconds: 2),
              ).show(context);
              return;
            }
            await Future.forEach(picked, (element) async {
              imageDatas
                  .add((await element.getByteData()).buffer.asUint8List());
            });
            setState(() {});
            widget.onImagesSelected(imageDatas);
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
                return GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: cCount,
                  children: [
                    ...List.generate(
                      imageDatas.length,
                      (index) => SizedBox(
                        height: c.maxWidth / cCount,
                        width: c.maxWidth / cCount,
                        child: RemovableImageWidget(
                          data: imageDatas[index],
                          onRemove: () {
                            setState(() {
                              imageDatas.removeAt(index);
                            });
                          },
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          },
        )
      ],
    );
  }
}
