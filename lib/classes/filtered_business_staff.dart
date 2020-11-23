import 'package:bapp/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import 'firebase_structures/business_booking.dart';
import 'firebase_structures/business_staff.dart';
import 'firebase_structures/business_timings.dart';

class FilteredBusinessStaff {
  final BusinessStaff staff;
  final busyTimings = ObservableList<FromToTiming>();
  final freeTimings = ObservableList<FromToTiming>();
  final bookedState =
      Observable<BusinessStaffBookedState>(BusinessStaffBookedState.no);
  final List<BusinessBooking> bookings;
  final stepMinutes, selectedDurationMinutes;
  final BusinessTimings businessTimings;
  DateTime selectedDay;

  List<ReactionDisposer> _disposers = [];

  FilteredBusinessStaff(
      {this.staff,
      this.bookings,
      this.stepMinutes,
      this.selectedDurationMinutes,
      this.businessTimings,
      this.selectedDay}) {
    computeForDay(selectedDay);
  }

  void computeForDay(DateTime day) {
    selectedDay = day;
    _computeBusyAndFreeTime();
    _computeBookedState();
  }

  final morningTimings = ObservableList<FromToTiming>();
  void _morningFreeTimings() {
    final maxMorning = TimeOfDay(hour: 12, minute: 1);
    final minMorning = TimeOfDay(hour: 0, minute: 0);
    final list = freeTimings.where((e) {
      return e.to.toTimeOfDay().isBefore(maxMorning) &&
          e.from.toTimeOfDay().isAfter(minMorning);
    });
    morningTimings.clear();
    morningTimings.addAll(list.toList() ?? []);
  }

  final afterNoonTimings = ObservableList<FromToTiming>();
  void _afterNoonFreeTimings() {
    final maxAfternoon = TimeOfDay(hour: 15, minute: 1);
    final minAfternoon = TimeOfDay(hour: 11, minute: 59);
    final list = freeTimings.where((e) {
      return e.to.toTimeOfDay().isBefore(maxAfternoon) &&
          e.from.toTimeOfDay().isAfter(minAfternoon);
    });
    afterNoonTimings.clear();
    afterNoonTimings.addAll(list.toList() ?? []);
  }

  final eveTimings = ObservableList<FromToTiming>();
  void _eveningFreeTimings() {
    final maxEve = TimeOfDay(hour: 23, minute: 59);
    final minEve = TimeOfDay(hour: 14, minute: 59);
    final list = freeTimings.where((e) {
      return e.to.toTimeOfDay().isBefore(maxEve) &&
          e.from.toTimeOfDay().isAfter(minEve);
    });
    eveTimings.clear();
    eveTimings.addAll(list.toList() ?? []);
  }

  void _computeBusyAndFreeTime() {
    freeTimings.clear();
    bookings.forEach((b) {
      if (b.fromToTiming.from.isDay(selectedDay)) {
        busyTimings.add(b.fromToTiming);
      }
    });
    final _buzyList = <TimeOfDay>[];
    busyTimings.forEach((bt) {
      _buzyList.addAll([bt.from.toTimeOfDay(), bt.to.toTimeOfDay()]);
    });
    _buzyList.sort((a, b) {
      return a.compareTo(b);
    });
    _buzyList.removeSuccessiveCopies((a, b) => a.isSame(b));
    final _workList = <TimeOfDay>[];
    businessTimings.getForDay(selectedDay).forEach((wh) {
      _workList.addAll([wh.from.toTimeOfDay(), wh.to.toTimeOfDay()]);
    });
    _workList.sort((a, b) {
      return a.compareTo(b);
    });
    for (var i = 0; i < _buzyList.length; i += 2) {
      final existing = _workList.firstWhere(
          (element) => element.isSame(_buzyList[i]),
          orElse: () => null);
      if (existing != null) {
        _workList[_workList.indexOf(existing)] = _buzyList[i + 1];
      } else {
        _workList.addAll([_buzyList[i], _buzyList[i + 1]]);
      }
    }
    _workList.sort((a, b) {
      return a.compareTo(b);
    });
    final list = <FromToTiming>[];
    for (var i = 0; i < _workList.length; i += 2) {
      list.add(
        FromToTiming.fromDates(
          from: _workList[i].toDateAndTime(),
          to: _workList[i + 1].toDateAndTime(),
        ),
      );
    }
    list.forEach((ftt) {
      freeTimings.addAll(
        ftt.splitInto(
            stepMinutes: stepMinutes, durationPadding: selectedDurationMinutes),
      );
    });
    final now = DateTime.now();
    freeTimings.removeWhere((ftt) => ftt.from.toDay(selectedDay).isBefore(now));
    _morningFreeTimings();
    _afterNoonFreeTimings();
    _eveningFreeTimings();
  }

  void _computeBookedState() {
    final btl = busyTimings.length;
    final ftl = freeTimings.length;
    if (ftl == 0) {
      bookedState.value = BusinessStaffBookedState.fully;
    } else if (btl == 0) {
      bookedState.value = BusinessStaffBookedState.no;
    } else if (btl > ftl) {
      bookedState.value = BusinessStaffBookedState.almost;
    } else if (btl < ftl) {
      bookedState.value = BusinessStaffBookedState.partially;
    }
  }
}

enum BusinessStaffBookedState {
  no,
  partially,
  almost,
  fully,
}
