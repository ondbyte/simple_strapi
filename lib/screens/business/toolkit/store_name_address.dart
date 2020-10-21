import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/padded_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusinessStoreNameAddress extends StatefulWidget {
  BusinessStoreNameAddress({Key key}) : super(key: key);

  @override
  _BusinessStoreNameAddressState createState() =>
      _BusinessStoreNameAddressState();
}

class _BusinessStoreNameAddressState extends State<BusinessStoreNameAddress> {
  String _storeName = "", _beforeName = "";
  String _storeAddress = "", _beforeAddress = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_storeAddress.isNotEmpty) {
            if (_storeAddress != _beforeAddress) {
              await act(
                () {
                  Provider.of<BusinessStore>(context, listen: false)
                      .business
                      .selectedBranch
                      .value
                      .address
                      .value = _storeAddress;
                },
              );
            }
          }
          if (_storeName.isNotEmpty) {
            if (_storeName != _beforeName) {
              await act(
                () {
                  Provider.of<BusinessStore>(context, listen: false)
                      .business
                      .selectedBranch
                      .value
                      .name
                      .value = _storeName;
                },
              );
            }
          }
          return true;
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
                    Consumer<BusinessStore>(
                      builder: (_, businessStore, __) {
                        _beforeName = businessStore
                            .business.selectedBranch.value.name.value;
                        return TextFormField(
                          maxLength: 32,
                          maxLengthEnforced: true,
                          initialValue: _beforeName,
                          decoration: InputDecoration(
                            labelText: "Store name",
                          ),
                          onChanged: (s) {
                            _storeName = s;
                          },
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Consumer<BusinessStore>(
                      builder: (_, businessStore, __) {
                        _beforeAddress = businessStore
                            .business.selectedBranch.value.address.value;
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
