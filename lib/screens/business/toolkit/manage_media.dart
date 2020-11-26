import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/add_image_sliver.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import 'manage_services/add_a_service.dart';

class BusinessManageMediaScreen extends StatefulWidget {
  BusinessManageMediaScreen({Key key}) : super(key: key);

  @override
  _BusinessManageMediaScreenState createState() =>
      _BusinessManageMediaScreenState();
}

class _BusinessManageMediaScreenState extends State<BusinessManageMediaScreen> {
  final Map<String, bool> _images = {};
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Add Branch images"),
      ),
      bottomNavigationBar: BottomPrimaryButton(
        label: "Update",
        onPressed: !_loading
            ? () async {
                if (_images.isEmpty) {
                  Navigator.of(context).pop();
                  return;
                }
                setState(() {
                  _loading = true;
                });
                Flushbar(
                  message: "Uploading images..",
                  duration: const Duration(seconds: 2),
                ).show(context);
                await Provider.of<BusinessStore>(context, listen: false)
                    .business
                    .selectedBranch
                    .value
                    .updateImages(imgs: _images);
                Navigator.of(context).pop();
              }
            : null,
      ),
      body: _loading
          ? LoadingWidget()
          : Padding(
              padding: EdgeInsets.zero,
              child: Consumer<BusinessStore>(
                builder: (_, businessStore, __) {
                  return Observer(
                    builder: (_) {
                      final images =
                          businessStore.business.selectedBranch.value.images;
                      //Helper.printLog("FSTORAGE");
                      //print(images);
                      return AddImageTileWidget(
                        existingImages: images,
                        maxImage: 6,
                        title: "Add Images",
                        subTitle:
                            "Add upto 6 Images that show off your business",
                        onImagesSelected: (images) {
                          _images.clear();
                          _images.addAll(images);
                        },
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
