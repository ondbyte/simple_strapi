import 'package:flutter/material.dart';

class StoreProvider<T> extends StatelessWidget {
  final Function(T store) init;
  final T store;
  final Widget Function(BuildContext context,T store) builder;
  StoreProvider({Key key,this.store,this.builder,this.init}) : super(key: key){
    if(init!=null){
      init(store);
    }
  }

  @override
  Widget build(BuildContext context) {
    return builder(context,store);
  }
}
