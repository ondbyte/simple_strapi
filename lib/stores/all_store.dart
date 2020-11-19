import 'package:mobx/mobx.dart';

class AllStore{
  final _all = [];
  void set<T>(T store){
    if(_all.any((element) => element.runtimeType==T)){
      throw Exception("This should never be the case @AllStore set");
    }
    _all.add(store);
  }

  T get<T>(){
    final t = _all.firstWhere((element) => element.runtimeType==T);
    if(t==null){
      throw Exception("This should never be the case @AllStore get");
    }
    return t;
  }
}