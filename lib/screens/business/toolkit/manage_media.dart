import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:bapp/widgets/tiles/add_image_sliver.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
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
  final _changed = Observable<bool>(false);
  @override
  Widget build(BuildContext context) {
    return LoadingStackWidget(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text("Add Branch images"),
        ),
        bottomNavigationBar: Observer(
          builder: (_) {
            final b = !_changed.value;
            return BottomPrimaryButton(
              label: "Update",
              onPressed: b
                  ? null
                  : () async {
                      if (_images.isEmpty) {
                        Navigator.of(context).pop();
                        return;
                      }
                      act(() {
                        kLoading.value = true;
                      });
                      Flushbar(
                        message: "Updating images..",
                        duration: const Duration(seconds: 2),
                      ).show(context);
                      await Provider.of<BusinessStore>(context, listen: false)
                          .business
                          .selectedBranch
                          .value
                          .updateImages(imgs: _images);
                      Navigator.of(context).pop();
                      act(() {
                        kLoading.value = false;
                      });
                    },
            );
          },
        ),
        body: Padding(
          padding: EdgeInsets.zero,
          child: Consumer<BusinessStore>(
            builder: (_, businessStore, __) {
              return Observer(
                builder: (_) {
                  return AddImageTileWidget(
                    existingImages:
                        businessStore.business.selectedBranch.value.images,
                    maxImage: 6,
                    title: "Add Images",
                    subTitle: "Add upto 6 Images that show off your business",
                    onImagesSelected: (images) {
                      _images.clear();
                      _images.addAll(images);
                      act(() {
                        _changed.value = true;
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
