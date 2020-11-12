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
  final totalDurationMinutes = Observable(0);
  final totalPrice = Observable(0.0);

  BusinessBranch get branch => _branch.value;
  set branch(BusinessBranch v) {
    act(() {
      _branch.value = v;
    });
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
          if (_branch.value != null) {}
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => services.length,
        (_) {
          totalPrice.value = 0;
          totalDurationMinutes.value = 0;
          services.forEach(
            (s) {
              totalDurationMinutes.value += s.duration.value.inMinutes;
              totalPrice.value += s.price.value;
            },
          );
          
        },
      ),
    );
  }

  void dispose() {
    _disposers.forEach((element) {
      element.call();
    });
  }
}
