import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../helpers/helper.dart';
import 'firebase_structures/business_branch.dart';
import 'firebase_structures/business_details.dart';
import 'firebase_structures/business_services.dart';
import 'firebase_structures/business_timings.dart';

class BookingFlow {
  final _branch = Observable<BusinessBranch>(null);
  final services = ObservableList<BusinessService>();
  final List<ReactionDisposer> _disposers = [];

  BusinessBranch get branch=>_branch.value;
  set branch(BusinessBranch v){
    act((){_branch.value = v;});
  }

  BookingFlow() {
    _setupReactions();
  }
  
  void _setupReactions() {
    _disposers.add(
      reaction(
        (_) => _branch,
        (_) {
          services.clear();
          if(_branch.value!=null){

          }
        },
      ),
    );
  }
  
  void dispose(){
    _disposers.forEach((element) {element.call();});
  }
}
