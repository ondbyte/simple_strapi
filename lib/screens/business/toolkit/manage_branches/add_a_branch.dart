import 'dart:typed_data';

import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/add_image_sliver.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/shake_widget.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:bapp/widgets/wheres_it_located.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class BusinessAddABranchScreen extends StatefulWidget {
  BusinessAddABranchScreen({Key key}) : super(key: key);

  @override
  _BusinessAddABranchScreenState createState() =>
      _BusinessAddABranchScreenState();
}

class _BusinessAddABranchScreenState extends State<BusinessAddABranchScreen> {
  PickedLocation _pickedLocation;
  Map<String, bool> _filteredExistingImages;
  bool _doShakePlace = false;
  bool _doShakePhotos = false;
  final _pickedImages = <Asset>[];
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: _loading
          ? LoadingWidget()
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Text(
                          "What is the name of your branch?",
                          style: Theme.of(context).textTheme.headline1,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        StoreProvider<BusinessStore>(
                          store: Provider.of<BusinessStore>(context),
                          init: (businessStore) {
                            if (_controller.text.isEmpty) {
                              _controller.text =
                                  businessStore.business.businessName.value;
                            }
                          },
                          builder: (_, businessStore) {
                            return TextFormField(
                              controller: _controller,
                              style: Theme.of(context).textTheme.headline3,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (s) {
                                if (s.length < 3) {
                                  return "Enter a valid branch name";
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ShakeWidget(
                          doShake: _doShakePlace,
                          onShakeDone: () {
                            setState(() {
                              _doShakePlace = false;
                            });
                          },
                          child: WheresItLocatedTileWidget(
                            onPickLocation: (p) {
                              _pickedLocation = p;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        ShakeWidget(
                          doShake: _doShakePhotos,
                          onShakeDone: () {
                            setState(
                              () {
                                _doShakePhotos = false;
                              },
                            );
                          },
                          child: AddImageTileWidget(
                            onImagesSelected: (filteredExistingImages) {
                              _filteredExistingImages = filteredExistingImages;
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
      bottomSheet: _loading
          ? null
          : ListTile(
              title: Text("Create a branch"),
              trailing: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).primaryColor,
              ),
              onTap: _controller.text.isEmpty
                  ? null
                  : () async {
                      if (_controller.text.length < 3) {
                        return;
                      }
                      if (_pickedLocation == null) {
                        setState(() {
                          _doShakePlace = true;
                        });
                        return;
                      }
                      if (_filteredExistingImages.isEmpty) {
                        setState(() {
                          _doShakePhotos = true;
                        });
                        return;
                      }
                      setState(() {
                        _loading = true;
                      });
                      final business =
                          Provider.of<BusinessStore>(context, listen: false)
                              .business;
                      await business.addABranch(
                          branchName: _controller.text,
                          pickedLocation: _pickedLocation,
                          imagesWithFiltered: _filteredExistingImages);
                      Navigator.of(context).pop();
                    },
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}