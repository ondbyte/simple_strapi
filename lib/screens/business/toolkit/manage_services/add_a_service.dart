import 'package:bapp/classes/firebase_structures/business_services.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:bapp/widgets/tiles/add_image_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessAddAServiceScreen extends StatefulWidget {
  final CatalogueItem service;

  const BusinessAddAServiceScreen({Key? key, required this.service})
      : super(key: key);

  @override
  _BusinessAddAServiceScreenState createState() =>
      _BusinessAddAServiceScreenState();
}

class _BusinessAddAServiceScreenState extends State<BusinessAddAServiceScreen> {
  final _key = GlobalKey<FormState>();
  late CatalogueItem _service;
  @override
  void initState() {
    _service = widget.service;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
    /* return LoadingStackWidget(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text("Add a service"),
        ),
        bottomNavigationBar: BottomPrimaryButton(
          subTitle: "",title: "",
          onPressed: () async {
            final businessStore =
                Provider.of<BusinessStore>(context, listen: false);
            if (_key.currentState?.validate()??false) {
              act(() {
                kLoading.value = true;
              });
              act(() {
                businessStore
                    .business.selectedBranch.value.businessServices.value
                    .save(service: _service);
                BappNavigator.pop(context, null);
              });
              act(() {
                kLoading.value = false;
              });
            }
          },
          label: widget.service==null?"Add":"Update",
          padding: const EdgeInsets.all(16),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Consumer2<BusinessStore, CloudStore>(
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
                                  value: _service?.category.value,
                                  decoration: const InputDecoration(
                                      labelText: "Category"),
                                  items: <
                                      DropdownMenuItem<
                                          BusinessServiceCategory>>[
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
                                      _service.category.value = c;
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
                              initialValue: _service.serviceName.value,
                              decoration: const InputDecoration(
                                  labelText: "Name of the product"),
                              validator: (s) {
                                if (s?.isEmpty??false) {
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
                                    initialValue:
                                        "" + _service.price.value.toString(),
                                    decoration: InputDecoration(
                                      labelText: "Price",
                                      suffix: Text(cloudStore
                                          .theNumber.country.currency),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (s) {
                                      final number = double.tryParse(s??"");
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
                                    initialValue: "" +
                                        _service.duration.value.inMinutes
                                            .toString(),
                                    decoration: const InputDecoration(
                                      labelText: "Duration",
                                      suffix: Text("Minutes"),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (s) {
                                      if (s?.contains(".")??false) {
                                        return "Please enter valid duration";
                                      }
                                      final number = int.tryParse(s??"");
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
                              initialValue: _service == null
                                  ? ""
                                  : _service.description.value,
                              decoration: const InputDecoration(
                                labelText: "Description",
                              ),
                              keyboardType: TextInputType.text,
                              validator: (s) {
                                if ((s?.length??0) < 10) {
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
                                _key.currentState?.validate();
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
      ),
    );
   */
  }
}

class BottomPrimaryButton extends StatefulWidget {
  final Future Function()? onPressed;
  final String? label, title, subTitle;
  final EdgeInsets? padding;

  const BottomPrimaryButton({
    Key? key,
    this.onPressed,
    required this.label,
    this.title,
    this.subTitle,
    this.padding,
  }) : super(key: key);
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
              padding: widget.padding ??
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              color: Theme.of(context).backgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.all(0),
                      title: (widget.title is String)
                          ? Text(
                              widget.title as String,
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          : SizedBox(),
                      subtitle: (widget.subTitle is String)
                          ? Text(
                              widget.subTitle as String,
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          : SizedBox(),
                    ),
                  (widget.label is String)
                      ? PrimaryButton(
                          widget.label as String,
                          onPressed: widget.onPressed,
                        )
                      : SizedBox(),
                  SizedBox(height: 30)
                ],
              ),
            ),
    );
  }
}
