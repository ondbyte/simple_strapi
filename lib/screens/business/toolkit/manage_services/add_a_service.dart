import 'package:bapp/classes/firebase_structures/business_services.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:bapp/widgets/tiles/add_image_sliver.dart';
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
  final _service = BusinessService.empty();

  @override
  Widget build(BuildContext context) {
    return LoadingStackWidget(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text("Add a service"),
        ),
        bottomNavigationBar: BottomPrimaryButton(
          onPressed: () async {
            final businessStore =
                Provider.of<BusinessStore>(context, listen: false);
            if (_key.currentState.validate()) {
              act(() {
                kLoading.value = true;
              });
              act(() {
                businessStore
                    .business.selectedBranch.value.businessServices.value
                    .addAService(
                        images: _service.images,
                        category: _category,
                        duration: _service.duration.value,
                        description: _service.description.value,
                        price: _service.price.value,
                        serviceName: _service.serviceName.value);
                Navigator.of(context).pop();
              });
              act(() {
                kLoading.value = false;
              });
            }
          },
          label: "Add",
          padding: const EdgeInsets.all(16),
        ),
        body: Consumer2<BusinessStore, CloudStore>(
          builder: (_, businessStore, cloudStore, __) {
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
                                  .business
                                  .selectedBranch
                                  .value
                                  .businessServices
                                  .value
                                  .allCategories
                                  .toList();
                              return DropdownButtonFormField<
                                  BusinessServiceCategory>(
                                decoration: const InputDecoration(
                                    labelText: "Category"),
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
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
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
                          const SizedBox(
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
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
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
                                    final number = int.tryParse(s) ?? 0;
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
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
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
                          const SizedBox(
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

class BottomPrimaryButton extends StatefulWidget {
  final Function onPressed;
  final String label, title, subTitle;
  final EdgeInsets padding;

  const BottomPrimaryButton(
      {Key key,
      this.onPressed,
      this.label,
      this.title,
      this.subTitle,
      this.padding})
      : super(key: key);
  @override
  _BottomPrimaryButtonState createState() => _BottomPrimaryButtonState();
}

class _BottomPrimaryButtonState extends State<BottomPrimaryButton> {
  @override
  Widget build(BuildContext context) {
    assert((widget.title != null && widget.subTitle != null ||
        (widget.title == null && widget.subTitle == null)));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutExpo,
      child: widget.onPressed == null
          ? const SizedBox()
          : Container(
              padding: widget.padding ?? const EdgeInsets.symmetric(vertical:0, horizontal: 16),
              color: Theme.of(context).backgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.all(0),
                      title: Text(widget.title, style: Theme.of(context).textTheme.subtitle1,),
                      subtitle: Text(widget.subTitle, style: Theme.of(context).textTheme.bodyText2,),
                    ),
                  PrimaryButton(
                    widget.label,
                    onPressed: widget.onPressed,
                  ),
                  SizedBox(
                    height:30
                  )
                ],
              ),
            ),
    );
  }
}
