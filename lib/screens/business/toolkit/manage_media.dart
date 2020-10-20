/* 

class BusinessManageMediaScreen extends StatefulWidget {
  @override
  _BusinessManageMediaScreenState createState() =>
      _BusinessManageMediaScreenState();
}

class _BusinessManageMediaScreenState extends State<BusinessManageMediaScreen> {
  final _listOfImageData = List<Uint8List>();
  final _pickedImages = List<Asset>();
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
                            final maxImages = 6 - _pickedImages.length;
                            //print(maxImages);
                            if (maxImages == 0) {
                              Flushbar(
                                message: "Maximum 6 images",
                                duration: const Duration(seconds: 2),
                              ).show(context);
                              return;
                            }
                            try {
                              _pickedImages.addAll(
                                await MultiImagePicker.pickImages(
                                  maxImages: maxImages,
                                ),
                              );

                              await Future.forEach(
                                _pickedImages,
                                (element) async {
                                  if (_pickedImages
                                      .any((el) => element.name == el.name)) {
                                    return;
                                  }

                                  _listOfImageData.add(
                                    (await element.getByteData())
                                        .buffer
                                        .asUint8List(),
                                  );
                                  _listOfImage.add("local" + element.name);

                                  setState(
                                    () {
                                      _loading = false;
                                    },
                                  );
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
                                if (_listOfImage[i].startsWith("local")) {
                                  return RemovableImageWidget(
                                    asset: _pickedImages[i],
                                    onRemove: () {
                                      setState(
                                        () {
                                          _listOfImage.removeAt(i);
                                          _pickedImages.removeAt(i);
                                          _listOfImageData.removeAt(i);
                                        },
                                      );
                                    },
                                  );
                                } else {
                                  return RemovableImageWidget(
                                    data: _listOfImageData[i],
                                    onRemove: () {
                                      setState(
                                        () {
                                          _listOfImage.removeAt(i);
                                          _pickedImages.removeAt(i);
                                          _listOfImageData.removeAt(i);
                                        },
                                      );
                                    },
                                  );
                                }
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
 */

import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/add_image_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class BusinessManageMediaScreen extends StatefulWidget {
  BusinessManageMediaScreen({Key key}) : super(key: key);

  @override
  _BusinessManageMediaScreenState createState() =>
      _BusinessManageMediaScreenState();
}

class _BusinessManageMediaScreenState extends State<BusinessManageMediaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Add Branch images"),
      ),
      body: Padding(
        padding: EdgeInsets.zero,
        child: Consumer<BusinessStore>(
          builder: (_, businessStore, __) {
            return Observer(
              builder: (_) {
                final images =
                    businessStore.business.selectedBranch.value.images.value;
                return AddImageTileWidget(
                  existingImages: Map.fromIterable(images,
                      key: (k) => k, value: (k) => true),
                  maxImage: 6,
                  title: "Add Images",
                  subTitle: "Add upto 6 Images that show off your business",
                  onImagesSelected: (images) {},
                );
              },
            );
          },
        ),
      ),
    );
  }
}
