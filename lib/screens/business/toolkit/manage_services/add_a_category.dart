import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:bapp/widgets/add_image_sliver.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusinessAddServiceCategoryScreen extends StatefulWidget {
  @override
  _BusinessAddServiceCategoryScreenState createState() =>
      _BusinessAddServiceCategoryScreenState();
}

class _BusinessAddServiceCategoryScreenState
    extends State<BusinessAddServiceCategoryScreen> {
  String _name = "";
  String _description = "";
  Map<String, bool> _image = {};
  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Add a category"),
        actions: [FlatButton(onPressed: () {}, child: Text(""))],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Form(
                    key: _key,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: "Category name"),
                          onChanged: (s) {
                            _name = s;
                          },
                          validator: (s) {
                            if (s.isEmpty) {
                              return "Enter a valid name";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: "Description"),
                          onChanged: (s) {
                            _description = s;
                          },
                          validator: (s) {
                            if (s.isEmpty) {
                              return "Enter a valid description";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                AddImageTileWidget(
                  maxImage: 1,
                  title: "Add an image",
                  subTitle: "(optional)",
                  onImagesSelected: (imgs) {
                    _image = imgs;
                  },
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  PrimaryButton(
                    "Apply",
                    onPressed: () async {
                      _name = _name.trim();
                      _description = _description.trim();
                      final business =
                          Provider.of<BusinessStore>(context, listen: false)
                              .business;
                      if (business.businessServices.value.allCategories
                          .any((c) => c.categoryName.value == _name)) {
                        Flushbar(
                          message: "That category exists",
                          duration: const Duration(
                            seconds: 2,
                          ),
                        ).show(context);
                        return;
                      }
                      await business.businessServices.value.addACategory(
                        categoryName: _name,
                        description: _description,
                        images: _image,
                      );
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
