import 'dart:typed_data';

import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/removable_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class BusinessManageMediaScreen extends StatefulWidget {
  @override
  _BusinessManageMediaScreenState createState() =>
      _BusinessManageMediaScreenState();
}

class _BusinessManageMediaScreenState extends State<BusinessManageMediaScreen> {
  List<Uint8List> _listOfImageData = List<Uint8List>();
  List<String> _listOfImage = List<String>();
  final _cache = DefaultCacheManager();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      initializer: () async {
        setState(() {
          _loading = true;
        });
        final businessStore =
            Provider.of<BusinessStore>(context, listen: false);
        final images = businessStore.business.selectedBranch.value.images.value;
        final storage = FirebaseStorage.instance;

        await Future.forEach(images, (element) async {
          final url = await storage.ref().child(element).getDownloadURL();
          final file = await _cache.getSingleFile(url);
          _listOfImageData.add(await file.readAsBytes());
          _listOfImage.add(element);
        });
        setState(() {
          _loading = false;
        });
      },
      child: WillPopScope(
          onWillPop: () async {
            setState(() {
              _loading = true;
            });
            final uploadFuture =
                Provider.of<BusinessStore>(context, listen: false)
                    .business
                    .selectedBranch
                    .value
                    .updateImages(_listOfImage, _listOfImageData);

            final flushBar = Flushbar(
              message: "Updating images, please wait",
              isDismissible: false,
            );
            flushBar.show(context);
            await uploadFuture;
            flushBar.dismiss();
            return true;
          },
          child: Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: _loading
                ? null
                : FloatingActionButton(
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).primaryColorLight,
                    ),
                    onPressed: _loading
                        ? null
                        : () async {
                            final maxImages = 6 - _listOfImage.length;
                            print(maxImages);
                            if (maxImages == 0) {
                              Flushbar(
                                message: "Maximum 6 images",
                                duration: const Duration(seconds: 2),
                              ).show(context);
                              return;
                            }
                            try {
                              final pI = await MultiImagePicker.pickImages(
                                maxImages: maxImages,
                              );

                              await Future.forEach(
                                pI,
                                (element) async {
                                  if (_listOfImage
                                      .any((el) => element.name == el)) {
                                    return;
                                  }

                                  _listOfImageData.add(
                                      (await element.getByteData())
                                          .buffer
                                          .asUint8List());
                                  _listOfImage.add("local" + element.name);

                                  setState(() {
                                    _loading = false;
                                  });
                                },
                              );
                            } catch (e, s) {
                              Flushbar(
                                message: "No images picked",
                                duration: const Duration(seconds: 2),
                              ).show(context);
                            }
                          },
                  ),
            appBar: AppBar(
              automaticallyImplyLeading: true,
              title: Text("Add photos"),
            ),
            body: _loading
                ? LoadingWidget()
                : Padding(
                    padding: EdgeInsets.all(16),
                    child: OrientationBuilder(
                      builder: (_, o) {
                        final count = o == Orientation.landscape ? 6 : 3;
                        return Consumer<BusinessStore>(
                          builder: (_, businessStore, __) {
                            return GridView.builder(
                              itemCount: _listOfImage.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: count,
                              ),
                              itemBuilder: (_, i) {
                                return RemovableImageWidget(
                                  data: _listOfImageData[i],
                                  onRemove: () {
                                    setState(
                                      () {
                                        _listOfImage.removeAt(i);
                                        _listOfImageData.removeAt(i);
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
          )),
    );
  }
}
