import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:flutter/material.dart';
import "package:provider/provider.dart";

class BranchChooserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Consumer<BusinessStore>(builder: (_,businessStore,__){
        return ListView.builder(
          itemCount: businessStore.business.branches.value.length,
          itemBuilder: (_,i){
          final tmp =businessStore.business.branches.value[i];
          return ListTile(
            title: Text(tmp.name,maxLines: 1,),
            subtitle: Text(tmp.address,maxLines: 1,),
            onTap: (){
              Navigator.pop(context,tmp );
            },
          );
        },);
      },),
    );
  }
}
