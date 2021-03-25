import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

class BusinessStoreNameAddress extends StatefulWidget {
  BusinessStoreNameAddress({Key? key}) : super(key: key);

  @override
  _BusinessStoreNameAddressState createState() =>
      _BusinessStoreNameAddressState();
}

class _BusinessStoreNameAddressState extends State<BusinessStoreNameAddress> {
  String _storeName = "", _beforeName = "";
  String _storeAddress = "", _beforeAddress = "";
  final _updatable = Observable(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Observer(
        builder: (_) {
          return BottomPrimaryButton(
            title: "",
            subTitle: "",
            label: "Update",
            onPressed: !_updatable.value
                ? () async {}
                : () async {
                    act(() {
                      _updatable.value = false;
                    });
                    if (_storeAddress.isNotEmpty) {
                      if (_storeAddress != _beforeAddress) {
                        await act(
                          () {
                          },
                        );
                      }
                    }
                    if (_storeName.isNotEmpty) {
                      if (_storeName != _beforeName) {
                        await act(
                          () {
                          },
                        );
                      }
                    }
                  },
          );
        },
      ),
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Text(
                      "Update details",
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Builder(
                      builder: (_,) {
                        return TextFormField(
                          maxLength: 32,
                          maxLengthEnforced: true,
                          initialValue: _beforeName,
                          decoration: InputDecoration(
                            labelText: "Store name",
                          ),
                          onChanged: (s) {
                            _storeName = s;
                            act(() {
                              _updatable.value = true;
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                   Builder(
                      builder: (_) {
                        return TextFormField(
                          maxLength: 256,
                          maxLengthEnforced: true,
                          maxLines: 5,
                          initialValue: _beforeAddress,
                          decoration: InputDecoration(
                            labelText: "Store address",
                          ),
                          onChanged: (s) {
                            _storeAddress = s;
                            act(() {
                              _updatable.value = true;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
