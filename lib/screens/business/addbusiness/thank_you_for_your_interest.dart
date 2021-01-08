import 'package:bapp/classes/firebase_structures/business_category.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/shake_widget.dart';
import 'package:bapp/widgets/wheres_it_located.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:the_country_number/the_country_number.dart';
import 'package:the_country_number_widgets/the_country_number_widgets.dart';

class ThankYouForYourInterestScreen extends StatefulWidget {
  final BusinessCategory category;
  final bool onBoard;

  const ThankYouForYourInterestScreen(
      {Key key, this.category, this.onBoard = false})
      : super(key: key);
  @override
  _ThankYouForYourInterestScreenState createState() =>
      _ThankYouForYourInterestScreenState();
}

class _ThankYouForYourInterestScreenState
    extends State<ThankYouForYourInterestScreen> {
  TheNumber _validNumber;
  PickedLocation _pickedLocation;
  bool _shake = false;
  String _businessName = "", _ownerName = "";
  String _genderSpecific = "";
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Consumer<CloudStore>(
          builder: (_, cloudStore, __) {
            return Form(
              key: _key,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          widget.onBoard
                              ? "Add other details"
                              : "Thank you for your interest",
                          style: Theme.of(context).textTheme.headline1,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.onBoard
                              ? "Business will be made draft on Bapp"
                              : "Please send us below information and we will on-board you as quickly as possible",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          onChanged: (s) {
                            setState(() {
                              _ownerName = s;
                            });
                          },
                          validator: (s) {
                            if (s.length < 3) {
                              return "Enter a valid name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText:
                            "Name of owner",
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          onChanged: (s) {
                            setState(() {
                              _businessName = s;
                            });
                          },
                          validator: (s) {
                            if (s.length < 3) {
                              return "Enter a valid business name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText:
                            "Name of ${widget.onBoard ? "the" : "your"} business",
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: "Type"),
                          onChanged: (s) {
                            _genderSpecific = s;
                          },
                          validator: (s) {
                            if (s == null || s.isEmpty) {
                              return "Select a specific gender ${widget.onBoard ? "the" : "your"} business serve";
                            }
                            return null;
                          },
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              value: "Ladies",
                              child: Text("Ladies"),
                            ),
                            DropdownMenuItem(
                              value: "Men",
                              child: Text("Men"),
                            ),
                            DropdownMenuItem(
                              value: "Unisex",
                              child: Text("Unisex"),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InitWidget(
                          initializer: () {
                            _validNumber = widget.onBoard
                                ? cloudStore.theNumber.removeNumber()
                                : cloudStore.theNumber;
                          },
                          child: TheCountryNumberInput(
                            widget.onBoard
                                ? cloudStore.theNumber.removeNumber()
                                : cloudStore.theNumber,
                            customValidator: (tn) {
                              if (tn == null) {
                                return "Enter a valid number";
                              }
                              if (tn.isValidLength) {
                                return null;
                              }
                              return "Enter a valid number";
                            },
                            onChanged: (tn) {
                              _validNumber = tn;
                              if (_validNumber.isValidLength) {
                                setState(
                                  () {},
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ShakeWidget(
                          doShake: _shake,
                          onShakeDone: () {
                            setState(
                              () {
                                _shake = false;
                              },
                            );
                          },
                          child: WheresItLocatedTileWidget(
                            title:
                                "Where is ${widget.onBoard ? "the" : "your"} business located",
                            caption: "Pick a location",
                            onPickLocation: (p) {
                              _pickedLocation = p;
                            },
                          ),
                        ),
                      ]),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
      bottomSheet: MaterialButton(
        onPressed: () {
          if (_key.currentState.validate()) {
            if (_pickedLocation != null) {
              BappNavigator.pushAndRemoveAll(
                context,
                ContextualMessageScreen(
                  message: widget.onBoard
                      ? "Business added to draft"
                      : "Thank you, we\'ll reach you out soon",
                  init: () async {
                    final tmp =
                        await Provider.of<BusinessStore>(context, listen: false)
                            .applyForBusiness(
                      latlong: _pickedLocation.latLong,
                      address: _pickedLocation.address,
                      businessName: _businessName,
                      contactNumber: _validNumber.internationalNumber,
                      category: widget.category,
                      type: _genderSpecific,
                      onBoard: widget.onBoard,
                    );
                    return tmp;
                  },
                ),
              );
            } else {
              setState(
                () {
                  _shake = true;
                },
              );
            }
          }
        },
        child: Row(
          children: [
            Text("Submit"),
            Spacer(),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
