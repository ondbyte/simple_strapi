import 'package:bapp/stores/business_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class BusinessBranchSwitchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessStore>(
      builder: (_, businessStore, __) {
        return GestureDetector(
          onTap: () {
            _showBranchSelector(context, businessStore.business.branches.value);
          },
          child: Row(
            children: [
              Observer(
                builder: (_) {
                  return Text(businessStore.business.selectedBranch.value.name);
                },
              ),
              SizedBox(
                width: 4,
              ),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        );
      },
    );
  }

  _showBranchSelector(BuildContext context, List<BusinessBranch> branches) {
    return showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: ListView.builder(
            itemCount: branches.length,
            itemBuilder: (_, i) {
              return ListTile(
                onTap: (){
                  Provider.of<BusinessStore>(context,listen: false).business.selectedBranch.value = branches[i];
                  Navigator.pop(context);
                },
                title: Text(
                  branches[i].name,
                  maxLines: 1,
                ),
                subtitle: Text(
                  branches[i].address,
                  maxLines: 3,
                ),
                trailing: Icon(Icons.arrow_forward_ios),
              );
            },
          ),
        );
      },
    );
  }
}
