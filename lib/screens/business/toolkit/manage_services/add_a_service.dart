import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:bapp/widgets/add_image_sliver.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class BusinessAddAServiceScreen extends StatefulWidget {
  @override
  _BusinessAddAServiceScreenState createState() =>
      _BusinessAddAServiceScreenState();
}

class _BusinessAddAServiceScreenState extends State<BusinessAddAServiceScreen> {
  final _key = GlobalKey<FormState>();
  BusinessServiceCategory _category;
  @override
  Widget build(BuildContext context) {
    return LoadingStackWidget(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text("Add a service"),
        ),
        body: Consumer2<BusinessStore, CloudStore>(
          builder: (_, businessStore, cloudStore, __) {
            final collecPath =
                businessStore.business.businessServices.value.myCollec;
            final BusinessService _service = BusinessService(
              myDoc: FirebaseFirestore.instance.collection(collecPath).doc(
                    kUUIDGen.v1(),
                  ),
            );
            return Form(
              key: _key,
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Observer(
                            builder: (_) {
                              final categories = businessStore
                                  .business.businessServices.value.allCategories
                                  .toList();
                              return DropdownButtonFormField<
                                  BusinessServiceCategory>(
                                decoration:
                                    InputDecoration(labelText: "Category"),
                                items: <
                                    DropdownMenuItem<BusinessServiceCategory>>[
                                  ...List.generate(
                                    categories.length,
                                    (index) => DropdownMenuItem(
                                      child: Text(
                                        categories[index].categoryName.value,
                                      ),
                                      value: categories[index],
                                    ),
                                  )
                                ],
                                validator: (s) {
                                  if (s == null) {
                                    return "Please select a category";
                                  }
                                  return null;
                                },
                                onChanged: (c) {
                                  act(() {
                                    _category = c;
                                  });
                                  FocusScope.of(context).nextFocus();
                                },
                              );
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: "Name of the product"),
                            validator: (s) {
                              if (s.isEmpty) {
                                return "Please enter the name of the product";
                              }
                              return null;
                            },
                            onChanged: (s) {
                              act(() {
                                _service.serviceName.value = s;
                              });
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: "Price",
                                    suffix: Text(cloudStore.theNumber.currency),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (s) {
                                    final number = double.tryParse(s);
                                    if (number == null) {
                                      return "Please enter the correct price of the product";
                                    }
                                    return null;
                                  },
                                  onChanged: (s) {
                                    final number = double.tryParse(s);
                                    act(() {
                                      _service.price.value = number;
                                    });
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: "Duration",
                                    suffix: Text("Minutes"),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (s) {
                                    if (s.contains(".")) {
                                      return "Please enter valid duration";
                                    }
                                    final number = int.tryParse(s);
                                    if (number == null) {
                                      return "Please enter valid duration";
                                    }
                                    return null;
                                  },
                                  onChanged: (s) {
                                    final number = int.tryParse(s);
                                    act(
                                      () {
                                        _service.duration.value =
                                            Duration(minutes: number);
                                      },
                                    );
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Description",
                            ),
                            keyboardType: TextInputType.text,
                            validator: (s) {
                              if (s.length < 10) {
                                return "Please enter valid description";
                              }
                              return null;
                            },
                            onChanged: (s) {
                              act(
                                () {
                                  _service.description.value = s;
                                },
                              );
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                              _key.currentState.validate();
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          AddImageTileWidget(
                            title: "Add a Image",
                            subTitle: "(optional)",
                            maxImage: 1,
                            padding: EdgeInsets.zero,
                            existingImages: _service.images,
                            onImagesSelected: (imgs) {
                              _service.images.clear();
                              _service.images.addAll(imgs);
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          PrimaryButton(
                            "Apply",
                            onPressed: () async {
                              if (_key.currentState.validate()) {
                                act(() {
                                  kLoading.value = true;
                                });
                                act(() {
                                  businessStore.business.businessServices.value
                                      .addAService(
                                          images: _service.images,
                                          category: _category,
                                          duration: _service.duration.value,
                                          description:
                                              _service.description.value,
                                          price: _service.price.value,
                                          serviceName:
                                              _service.serviceName.value);
                                  Navigator.of(context).pop();
                                });
                                act(() {
                                  kLoading.value = false;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
