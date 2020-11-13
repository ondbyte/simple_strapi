import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';

import '../helpers/helper.dart';
import 'firebase_structures/business_branch.dart';
import 'firebase_structures/business_details.dart';
import 'firebase_structures/business_services.dart';
import 'firebase_structures/business_staff.dart';
import 'firebase_structures/business_timings.dart';
import 'package:bapp/helpers/extensions.dart';

class BookingFlow {
  final _branch = Observable<BusinessBranch>(null);
  final services = ObservableList<BusinessService>();
  final totalDurationMinutes = Observable(0);
  final totalPrice = Observable(0.0);
  final professional = Observable<BusinessStaff>(null);
  final selectedTitle = Observable("");
  final selectedSubTitle = Observable("");
  final filteredStaffs = ObservableList<FilteredBusinessStaff>();
  final _bookings = ObservableList<BusinessBooking>();
  final timeWindow = Observable<FromToTiming>(FromToTiming.today());

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

  Future _getBookings() async {
    final bookingSnaps = await FirebaseFirestore.instance
        .collection("bookings")
        .where("branch", isEqualTo: branch.myDoc)
        .where("from",
            isGreaterThanOrEqualTo: timeWindow.value.from.toTimeStamp())
        .where("to", isLessThanOrEqualTo: timeWindow.value.to.toTimeStamp())
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
  }

  void _filterStaffAndBookings(){
    if(_bookings.isEmpty){
      return;
    }
    filteredStaffs.clear();
    final staffWithBookings = <BusinessStaff,List<BusinessBooking>>{};
    _bookings.forEach((b) {
      if(staffWithBookings.keys.any((bs) => bs.name==b.staff.name)){
        staffWithBookings[b.staff] = [...staffWithBookings[b.staff],b];
      } else {
        staffWithBookings.addAll({b.staff:[b]});
      }
    });
    staffWithBookings.forEach((bs, bbs) { 
      filteredStaffs.add(FilteredBusinessStaff(staff: bs,bookings:bbs,stepMinutes:15,workHours: _getWorkHours()));
    });
  }

  List<FromToTiming> _getWorkHours(){
    final todayName = DateFormat(DateFormat.WEEKDAY).format(timeWindow.value.from);
    final allDayTiming = branch.businessTimings.value.allDayTimings.value;
    final todayTimings = allDayTiming.firstWhere((dt) => dt.dayName==todayName);
    return todayTimings.timings.value.toList();
  }

  BusinessStaff getStaffFor(String name) {
    return branch.staff.firstWhere((s) => s.name == name);
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
          _setPriceDuration();
          _setTitleSubTitle();
        },
      ),
    );

    _disposers.add(
      reaction(
            (_) => professional,
            (_) async {
          if(professional.value!=null){
            await _filterStaffAndBookings();
          }
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => timeWindow.value,
        (_) async {
          await _getBookings();
          _filterStaffAndBookings();
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

  List<ReactionDisposer> _disposers = [];

  FilteredBusinessStaff({this.staff,List<BusinessBooking> bookings,int stepMinutes,List<FromToTiming> workHours,}){
    _computeBusyAndFreeTime(bookings,stepMinutes,workHours);
    _computeBookedState();
  }
  
  void _computeBusyAndFreeTime(List<BusinessBooking> bookings,int stepMinutes,List<FromToTiming> workHours,){
    bookings.forEach((b) {
      busyTimings.add(b.fromToTiming);
    });
    final workHoursWithoutBusy = <FromToTiming>[];
    workHours.forEach((ftt) {
      ftt.punchHoles(busyTimings);
    });
    final allTimings = <FromToTiming>[];
    workHours.forEach((ftt) {
      allTimings.addAll(ftt.splitInto(stepMinutes:stepMinutes));
    });

  }
  
  void _computeBookedState(){
    final btl = busyTimings.length;
    final ftl = freeTimings.length;
    if(ftl == 0){
      bookedState.value = BusinessStaffBookedState.fully;
    } else if(btl==0){
      bookedState.value = BusinessStaffBookedState.no;
    } else if(btl>ftl){
      bookedState.value = BusinessStaffBookedState.almost;
    } else if(btl<ftl){
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
