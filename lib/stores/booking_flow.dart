import 'dart:collection';

import 'package:bapp/classes/filtered_business_staff.dart';
import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/classes/firebase_structures/business_services.dart';
import 'package:bapp/classes/firebase_structures/business_staff.dart';
import 'package:bapp/classes/firebase_structures/business_timings.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';
import 'package:thephonenumber/thephonenumber.dart';

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
  final branchBookings = ObservableList<BusinessBooking>();
  final timeWindow = Observable<FromToTiming>(FromToTiming.today());
  final holidays = ObservableMap<DateTime, List>();
  final slot = Observable<DateTime>(null);
  final myBookings = ObservableList<BusinessBooking>();

  AllStore _allStore;

  void setAllStore(AllStore allStore) => _allStore = allStore;

  Map<DateTime, List> myBookingsAsCalendarEvents() {
    final map = <DateTime, List>{};
    myBookings.forEach((element) {
      final day = element.fromToTiming.from;
      map.addAll({day: getMyBookingsForDay(day)});
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
    timeWindow.value = FromToTiming.today();
    slot.value = null;
    branchBookings.clear();
  }

  final List<ReactionDisposer> _disposers = [];

  BusinessBranch get branch => _branch.value;
  set branch(BusinessBranch v) {
    act(() {
      _branch.value = v;
    });
  }

  BookingFlow(this._allStore) {
    _setupReactions();
  }

  List<BusinessBooking> getBookingsForDay(DateTime day) {
    return branchBookings
        .where((element) => element.fromToTiming.from.isDay(day))
        .toList();
  }

  List<BusinessBooking> getMyBookingsForDay(DateTime day) {
    return myBookings
        .where((element) => element.fromToTiming.from.isDay(day))
        .toList();
  }

  List<BusinessBooking> getStaffBookingsForDay(DateTime day) {
    assert(professional.value != null);
    return branchBookings
        .where((element) =>
            element.fromToTiming.from.isDay(day) &&
            element.staff.name == professional.value.staff.name)
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
            isEqualTo: FirebaseAuth.instance.currentUser.phoneNumber)
        .get();

    myBookings.clear();
    await Future.forEach(bookingSnaps.docs, (booking) async {
      final data = booking.data();
      final cloudStore = _allStore.get<CloudStore>();
      final b = await cloudStore.getBranch(reference: booking["branch"]);
      myBookings.add(
        BusinessBooking(
            services: (data["services"] as List).map(
              (s) {
                return BusinessService.fromJson(s);
              },
            ).toList(),
            staff: b.getStaffFor(name: data["staff"]),
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
            bookingUserType: EnumToString.fromString(
                UserType.values, data["bookingUserType"]))
          ..myDoc = booking.reference,
      );
    });
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

    branchBookings.clear();
    await Future.forEach(
      bookingSnaps.docs,
      (booking) async {
        final data = booking.data();
        final cloudStore = _allStore.get<CloudStore>();
        final b = await cloudStore.getBranch(reference: booking["branch"]);
        branchBookings.add(
          BusinessBooking(
              services: (data["services"] as List).map(
                (s) {
                  return BusinessService.fromJson(s);
                },
              ).toList(),
              staff: b.getStaffFor(name: data["staff"]),
              branch: b,
              fromToTiming: FromToTiming.fromTimeStamps(
                from: data["from"],
                to: data["to"],
              ),
              status: EnumToString.fromString(
                  BusinessBookingStatus.values, data["status"]),
              bookedByNumber: data["bookedByNumber"],
              bookingUserType: EnumToString.fromString(
                  UserType.values, data["bookingUserType"]))
            ..myDoc = booking.reference,
        );
      },
    );
    _filterStaffAndBookings();
  }

  void _filterStaffAndBookings() {
    filteredStaffs.clear();
    final staffWithBookings =
        LinkedHashMap<BusinessStaff, List<BusinessBooking>>(
      equals: (a, b) => a == b,
      hashCode: (k) => k.hashCode,
    );
    branch.staff.forEach((s) {
      staffWithBookings.addAll({s: <BusinessBooking>[]});
    });
    branchBookings.forEach((b) {
      if (staffWithBookings.keys.any((bs) => bs.name == b.staff.name)) {
        final tmp = staffWithBookings[b.staff] ?? [];
        staffWithBookings[b.staff] = tmp.isEmpty ? [b] : [...tmp, b];
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
            selectedDay: timeWindow.value.from,
          ),
        );
      },
    );
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
    if (_allStore.get<CloudStore>().userType != UserType.customer) {
      _disposers.add(reaction(
          (_) => _allStore.get<BusinessStore>().business.selectedBranch.value,
          (b) {
        branch = b;
      }));
    }

    _disposers.add(reaction((_) => professional.value, (p) {
      //services.clear();
      slot.value = null;
      timeWindow.value = FromToTiming.today();
      //totalDurationMinutes.value = 0;
      //totalPrice.value = 0.0;
      //selectedSubTitle.value = "";
      //selectedTitle.value = "";
      holidays.clear();
      if (_branch.value != null) {
        _getHolidays();
      }
    }));
    _disposers.add(
      reaction(
        (_) => _branch.value,
        (_) {
          services.clear();
          slot.value = null;
          timeWindow.value = FromToTiming.today();
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
          if (_allStore.get<CloudStore>().userType == UserType.customer) {
            filteredStaffs.clear();
          }
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => timeWindow.value,
        (_) async {
          if (professional.value != null && timeWindow.value != null) {
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

  Future done({ThePhoneNumber number}) async {
    final from = slot.value.toDay(timeWindow.value.from);
    final to = slot.value
        .add(Duration(minutes: totalDurationMinutes.value))
        .toDay(timeWindow.value.from);
    final b = BusinessBooking(
      branch: branch,
      fromToTiming: FromToTiming.fromDates(from: from, to: to),
      staff: professional.value.staff,
      services: services,
      status: BusinessBookingStatus.walkin,
      bookedByNumber: number == null
          ? FirebaseAuth.instance.currentUser.phoneNumber
          : number.internationalNumber,
      bookingUserType: _allStore.get<CloudStore>().userType,
    );
    b.myDoc =
        await FirebaseFirestore.instance.collection("bookings").add(b.toMap());
    myBookings.add(b);
    act(reset);
  }
}
