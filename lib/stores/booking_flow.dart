import 'package:bapp/helpers/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../helpers/helper.dart';
import 'firebase_structures/business_branch.dart';
import 'firebase_structures/business_services.dart';
import 'firebase_structures/business_staff.dart';
import 'firebase_structures/business_timings.dart';

class BookingFlow {
  final _branch = Observable<BusinessBranch>(null);
  final services = ObservableList<BusinessService>();
  final totalDurationMinutes = Observable(0);
  final totalPrice = Observable(0.0);
  final professional = Observable<FilteredBusinessStaff>(null);
  final selectedTitle = Observable("");
  final selectedSubTitle = Observable("");
  final filteredStaffs = ObservableList<FilteredBusinessStaff>();
  final _bookings = ObservableList<BusinessBooking>();
  final timeWindow = Observable<FromToTiming>(null);
  final holidays = ObservableMap<DateTime, List>();
  final slot = Observable<DateTime>(null);

  final List<ReactionDisposer> _disposers = [];

  BusinessBranch get branch => _branch.value;
  set branch(BusinessBranch v) {
    act(() {
      _branch.value = v;
    });
  }

  BookingFlow() {
    _setupReactions();
  }

  Future getBookings() async {
    final bookingSnaps = await FirebaseFirestore.instance
        .collection("bookings")
        .where("branch", isEqualTo: branch.myDoc.value)
        .where("from", isGreaterThanOrEqualTo: DateTime.now().toTimeStamp())
        .where("from",
            isLessThanOrEqualTo:
                DateTime.now().add(Duration(days: 30)).toTimeStamp())
        .get();

    _bookings.clear();
    bookingSnaps.docs.forEach(
      (booking) {
        final data = booking.data();
        _bookings.add(
          BusinessBooking(
            services: (data["services"] as List).map(
              (s) {
                return BusinessService.fromJson(s);
              },
            ).toList(),
            staff: getStaffFor(data["staff"]),
            branch: branch,
            fromToTiming: FromToTiming.fromTimeStamps(
              from: data["from"],
              to: data["to"],
            ),
          ),
        );
      },
    );
    _filterStaffAndBookings();
  }

  void _filterStaffAndBookings() {
    filteredStaffs.clear();
    final staffWithBookings = <BusinessStaff, List<BusinessBooking>>{};
    branch.staff.forEach((s) {
      staffWithBookings.addAll({s: []});
    });
    _bookings.forEach((b) {
      if (staffWithBookings.keys.any((bs) => bs.name == b.staff.name)) {
        staffWithBookings[b.staff] = [...staffWithBookings[b.staff], b];
      }
    });
    staffWithBookings.forEach(
      (bs, bbs) {
        filteredStaffs.add(
          FilteredBusinessStaff(
              staff: bs,
              bookings: bbs,
              stepMinutes: 15,
              selectedDurationMinutes: totalDurationMinutes.value,
              businessTimings: branch.businessTimings.value,
              selectedDay: timeWindow.value.from),
        );
      },
    );
  }

  BusinessStaff getStaffFor(String name) {
    return branch.staff.firstWhere((s) => s.name == name);
  }

  void _getHolidays() {
    final hs = branch.businessHolidays.value.all;
    holidays.clear();
    hs.forEach((bh) {
      if (bh.enabled.value) {
        bh.dates.forEach((date) {
          holidays.addAll({
            date: [bh.name]
          });
        });
      }
    });
  }

  void _setupReactions() {
    _disposers.add(
      reaction(
        (_) => _branch.value,
        (_) {
          services.clear();
          slot.value = null;
          timeWindow.value = null;
          totalDurationMinutes.value = 0;
          totalPrice.value = 0.0;
          professional.value = null;
          selectedSubTitle.value = "";
          selectedTitle.value = "";
          filteredStaffs.clear();
          holidays.clear();
          slot.value = null;
          if (_branch.value != null) {
            _getHolidays();
          }
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => services.length,
        (_) {
          _setPriceDuration();
          _setTitleSubTitle();
          _filterStaffAndBookings();
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => timeWindow.value,
        (_) async {
          if (professional.value != null) {
            professional.value.computeForDay(timeWindow.value.from);
          }
        },
      ),
    );
  }

  void _setPriceDuration() {
    totalPrice.value = 0;
    totalDurationMinutes.value = 0;
    services.forEach(
      (s) {
        totalDurationMinutes.value += s.duration.value.inMinutes;
        totalPrice.value += s.price.value;
      },
    );
  }

  void _setTitleSubTitle() {
    if (services.isNotEmpty) {
      selectedTitle.value = services.length.toString() + " items selected";
      selectedSubTitle.value = totalDurationMinutes.value.toString() +
          " Minutes, " +
          totalPrice.value.toString() +
          " " +
          branch.misc.currency;
    } else {
      selectedTitle.value = "";
      selectedSubTitle.value = "";
    }
  }

  void dispose() {
    _disposers.forEach((element) {
      element.call();
    });
  }
}

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

class BusinessBooking {
  final BusinessStaff staff;
  final BusinessBranch branch;
  final FromToTiming fromToTiming;
  final List<BusinessService> services;

  BusinessBooking({this.staff, this.branch, this.fromToTiming, this.services});

  toMap() {
    return {
      "staff": staff.name,
      "from": fromToTiming.from.toTimeStamp(),
      "to": fromToTiming.to.toTimeStamp(),
      "services": services.map((e) => e.toMap()).toList(),
      "branch": branch.myDoc,
    };
  }
}
