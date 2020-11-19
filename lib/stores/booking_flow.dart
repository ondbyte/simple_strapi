import 'package:bapp/classes/filtered_business_staff.dart';
import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/classes/firebase_structures/business_services.dart';
import 'package:bapp/classes/firebase_structures/business_staff.dart';
import 'package:bapp/classes/firebase_structures/business_timings.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

import '../helpers/helper.dart';
import 'all_store.dart';

class BookingFlow {
  final _branch = Observable<BusinessBranch>(null);
  final services = ObservableList<BusinessService>();
  final totalDurationMinutes = Observable(0);
  final totalPrice = Observable(0.0);
  final professional = Observable<FilteredBusinessStaff>(null);
  final selectedTitle = Observable("");
  final selectedSubTitle = Observable("");
  final filteredStaffs = ObservableList<FilteredBusinessStaff>();
  final bookings = ObservableList<BusinessBooking>();
  final timeWindow = Observable<FromToTiming>(null);
  final holidays = ObservableMap<DateTime, List>();
  final slot = Observable<DateTime>(null);
  final myBookings = ObservableList<BusinessBooking>();

  AllStore _allStore;

  void setAllStore(AllStore allStore) => _allStore = allStore;

  Map<DateTime, List> myBookingsAsCalendarEvents() {
    final map = <DateTime, List>{};
    myBookings.forEach((element) {
      final day = element.fromToTiming.from;
      map.addAll({day: getBookingsForDay(day)});
    });
    return map;
  }

  reset() {
    _branch.value = null;
    services.clear();
    totalDurationMinutes.value = 0;
    totalPrice.value = 0.0;
    professional.value = null;
    selectedTitle.value = "";
    selectedSubTitle.value = "";
    filteredStaffs.clear();
    timeWindow.value = null;
    slot.value = null;
    bookings.clear();
  }

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

  List<BusinessBooking> getBookingsForDay(DateTime day) {
    return bookings
        .where((element) => element.fromToTiming.from.isDay(day))
        .toList();
  }

  List<BusinessBooking> getMyBookingsForDay(DateTime day) {
    return myBookings
        .where((element) => element.fromToTiming.from.isDay(day))
        .toList();
  }

  Future getMyBookings() async {
    if (FirebaseAuth.instance.currentUser.phoneNumber == null) {
      Helper.printLog("no number to get bookings");
      return;
    }
    final bookingSnaps = await FirebaseFirestore.instance
        .collection("bookings")
        .where("bookedByNumber",
            isGreaterThanOrEqualTo:
                FirebaseAuth.instance.currentUser.phoneNumber)
        .get();

    myBookings.clear();
    bookingSnaps.docs.forEach(
      (booking) async {
        final data = booking.data();
        final cloudStore = _allStore.get<CloudStore>();
        final b = await cloudStore.getBranch(reference: booking["branch"]);
        bookings.add(
          BusinessBooking(
            services: (data["services"] as List).map(
              (s) {
                return BusinessService.fromJson(s);
              },
            ).toList(),
            staff: getStaffFor(data["staff"]),
            branch: b,
            fromToTiming: FromToTiming.fromTimeStamps(
              from: data["from"],
              to: data["to"],
            ),
            status: EnumToString.fromString(
              BusinessBookingStatus.values,
              data["status"],
            ),
            bookedByNumber: data["bookedByNumber"],
          )..myDoc = booking.reference,
        );
      },
    );
  }

  Future getBranchBookings() async {
    final bookingSnaps = await FirebaseFirestore.instance
        .collection("bookings")
        .where("branch", isEqualTo: branch.myDoc.value)
        .where("from", isGreaterThanOrEqualTo: DateTime.now().toTimeStamp())
        .where("from",
            isLessThanOrEqualTo:
                DateTime.now().add(const Duration(days: 30)).toTimeStamp())
        .get();

    bookings.clear();
    bookingSnaps.docs.forEach(
      (booking) async {
        final data = booking.data();
        final cloudStore = _allStore.get<CloudStore>();
        final b = await cloudStore.getBranch(reference: booking["branch"]);
        bookings.add(
          BusinessBooking(
            services: (data["services"] as List).map(
              (s) {
                return BusinessService.fromJson(s);
              },
            ).toList(),
            staff: getStaffFor(data["staff"]),
            branch: b,
            fromToTiming: FromToTiming.fromTimeStamps(
              from: data["from"],
              to: data["to"],
            ),
            status: EnumToString.fromString(
                BusinessBookingStatus.values, data["status"]),
            bookedByNumber: data["bookedByNumber"],
          )..myDoc = booking.reference,
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
    bookings.forEach((b) {
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

  Future done() async {
    final from = slot.value.toDay(timeWindow.value.from);
    final to = slot.value
        .add(Duration(minutes: totalDurationMinutes.value))
        .toDay(timeWindow.value.from);
    final b = BusinessBooking(
      branch: branch,
      fromToTiming: FromToTiming.fromDates(from: from, to: to),
      staff: professional.value.staff,
      services: services,
      status: BusinessBookingStatus.pending,
      bookedByNumber: FirebaseAuth.instance.currentUser.phoneNumber,
    );
    b.myDoc =
        await FirebaseFirestore.instance.collection("bookings").add(b.toMap());
    bookings.add(b);
    act(reset);
  }
}
