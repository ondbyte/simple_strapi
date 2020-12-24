import 'dart:async';
import 'dart:collection';

import 'package:bapp/classes/filtered_business_staff.dart';
import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/classes/firebase_structures/business_services.dart';
import 'package:bapp/classes/firebase_structures/business_staff.dart';
import 'package:bapp/classes/firebase_structures/business_timings.dart';
import 'package:bapp/classes/firebase_structures/rating.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';
import 'package:the_country_number/the_country_number.dart';

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
    myBookings.forEach(
      (element) {
        final day = element.fromToTiming.from;
        map.update(
          day,
          (value) => value..add(element),
          ifAbsent: () => [element],
        );
      },
    );
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

  resetForBranch() {
    services.clear();
    totalDurationMinutes.value = 0;
    totalPrice.value = 0.0;
    selectedTitle.value = "";
    selectedSubTitle.value = "";
    timeWindow.value = FromToTiming.today();
    slot.value = null;
  }

  final List<ReactionDisposer> _disposers = [];

  BusinessBranch get branch => _branch.value;
  set branch(BusinessBranch v) {
    act(() {
      _branch.value = v;
    });
  }

  BookingFlow(this._allStore);

  void init() {
    _setupReactions();
  }

  List<BusinessBooking> getBookingsForSelectedDay(
      ObservableList<BusinessBooking> list) {
    return list
        .where(
          (element) => element.fromToTiming.from.isDay(timeWindow.value.from),
        )
        .toList();
  }

  List<BusinessBooking> getStaffBookingsForDay(DateTime day) {
    assert(professional.value != null);
    final list = branchBookings
        .where((element) =>
            element.fromToTiming.from.isDay(day) &&
            element.staff.name == professional.value.staff.name)
        .toList();
    return list;
  }

  Future getMyBookings() async {
    final completer = Completer<bool>();
    if (FirebaseAuth.instance.currentUser.phoneNumber == null) {
      Helper.printLog("no number to get bookings");
      return false;
    }
    FirebaseFirestore.instance
        .collection("bookings")
        .where("bookedByNumber",
            isEqualTo: FirebaseAuth.instance.currentUser.phoneNumber)
        .snapshots()
        .listen((bookingSnaps) async {
      ///clear old bookings;
      markRemoved(oldBookings: myBookings);
      final _bookings = <BusinessBooking>{};
      for (var booking in bookingSnaps.docs) {
        final cloudStore = _allStore.get<CloudStore>();
        final b = await cloudStore.getBranch(reference: booking["branch"]);
        final bkin = BusinessBooking.fromSnapShot(snap: booking, branch: b);
        _bookings.add(bkin);
      }
      myBookings.clear();
      myBookings.addAll(_bookings);
      completer.cautiousComplete(true);
    }, onDone: () {
      Helper.printLog("Listening for my bookings stopped");
      completer.cautiousComplete(false);
    }, onError: (e, s) {
      Helper.printLog("error while Listening for my bookings");
      completer.cautiousComplete(false);
    });
    return completer.future;
  }

  void markRemoved({ObservableList<BusinessBooking> oldBookings}) {
    act(() {
      oldBookings.forEach((element) {
        element.status.value = null;
      });
    });
  }

  StreamSubscription branchBookingSub;
  Future getBranchBookings() async {
    if (branchBookingSub != null) {
      branchBookingSub.cancel();
    }
    var q = FirebaseFirestore.instance
        .collection("bookings")
        .where("branch", isEqualTo: branch?.myDoc?.value)
        .where("from", isGreaterThanOrEqualTo: DateTime.now().toTimeStamp())
        .where("from",
            isLessThanOrEqualTo:
                DateTime.now().add(const Duration(days: 30)).toTimeStamp());
    if (_allStore.get<CloudStore>().bappUser.userType.value ==
        UserType.businessStaff) {
      q = q.where("staff", isEqualTo: branch.staff.first.name);
    }
    branchBookingSub = q.snapshots().listen(
      (bookingSnaps) async {
        if (branch != null) {
          markRemoved(oldBookings: branchBookings);
          branchBookings.clear();
          await Future.forEach<DocumentSnapshot>(
            bookingSnaps.docs,
            (booking) async {
              final cloudStore = _allStore.get<CloudStore>();
              final b =
                  await cloudStore.getBranch(reference: booking["branch"]);
              branchBookings.add(
                BusinessBooking.fromSnapShot(snap: booking, branch: b),
              );
            },
          );
          if (branch != null) {
            _filterStaffAndBookings();
          }
        }
      },
    );
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
        Helper.printLog(totalDurationMinutes.value);
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
    act(() {
      professional.value ??=
          filteredStaffs.isNotEmpty ? filteredStaffs.first : null;
    });
    if (filteredStaffs.isNotEmpty) {
      filteredStaffs.removeWhere(
          (element) => element.staff.role != UserType.businessStaff);
    }
  }

  void _getHolidays() {
    final hs = branch.businessHolidays.value.all;
    holidays.clear();
    hs.forEach(
      (bh) {
        if (bh.enabled.value) {
          bh.dates.forEach(
            (date) {
              holidays.addAll(
                {
                  date: [bh.name]
                },
              );
            },
          );
        }
      },
    );
  }

  void _setupReactions() {
    final cloudStore = _allStore.get<CloudStore>();
    cloudStore.hashCode;
    if (cloudStore.bappUser.userType.value != UserType.customer) {
      _disposers.add(
        reaction(
          (_) => _allStore.get<BusinessStore>().business.selectedBranch.value,
          (b) {
            branch = b;
            if (branch.staff.isNotEmpty) {
              professional.value = filteredStaffs.first;
            }
          },
        ),
      );
      _disposers.add(
        reaction(
          (_) => _allStore
              .get<BusinessStore>()
              .business
              .selectedBranch
              .value
              .staff
              .length,
          (v) async {
            await getBranchBookings();
          },
        ),
      );
    }

    _disposers.add(
      reaction(
        (_) => professional.value,
        (p) {
          slot.value = null;
          timeWindow.value = FromToTiming.today();
          holidays.clear();
          if (_branch.value != null) {
            _getHolidays();
          }
        },
      ),
    );
    _disposers.add(
      reaction(
        (_) => _branch.value,
        (_) {
          services.clear();
          slot.value = null;
          timeWindow.value = FromToTiming.today();
          totalDurationMinutes.value = 0;
          totalPrice.value = 0.0;
          if (_allStore.get<CloudStore>().bappUser.userType.value ==
              UserType.customer) {
            professional.value = null;
          }
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
          if (_allStore.get<CloudStore>().bappUser.userType.value ==
              UserType.customer) {
            filteredStaffs.clear();
          } else {
            _filterStaffAndBookings();
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
          branch.misc.country.currency;
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

  Future done({
    TheNumber number,
  }) async {
    final from = slot.value.toDay(timeWindow.value.from);
    final to = slot.value
        .add(Duration(minutes: totalDurationMinutes.value))
        .toDay(timeWindow.value.from);
    final doc = BusinessBooking.newDoc();
    final b = BusinessBooking(
      branch: branch,
      fromToTiming: FromToTiming.fromDates(from: from, to: to),
      staff: professional.value.staff,
      services: services,
      status: number == null
          ? BusinessBookingStatus.pending
          : BusinessBookingStatus.walkin,
      bookedByNumber: number == null
          ? FirebaseAuth.instance.currentUser.phoneNumber
          : number.internationalNumber,
      bookingUserType: _allStore.get<CloudStore>().bappUser.userType.value,
      remindTime: from.subtract(const Duration(hours: 2)),
      myDoc: doc,
      bookedByName:
          number == null ? FirebaseAuth.instance.currentUser.displayName : "",
      rating: CompleteBookingRating(),
      staffNumber: professional.value.staff.contactNumber.internationalNumber,
      receptionistNumber: branch
              .getStaffForRole(role: UserType.businessReceptionist)
              ?.contactNumber
              ?.internationalNumber ??
          "",
      managerNumber: branch
              .getStaffForRole(role: UserType.businessManager)
              ?.contactNumber
              ?.internationalNumber ??
          "",
      ownerNumber: branch
              .getStaffForRole(role: UserType.businessOwner)
              ?.contactNumber
              ?.internationalNumber ??
          "",
    );
    await b.save();
    if (number == null) {
      act(reset);
    } else {
      act(resetForBranch);
    }
  }

  List<BusinessBooking> getNewBookings() {
    final now = DateTime.now();
    return branchBookings
        .where((element) =>
            element.status.value == BusinessBookingStatus.pending &&
            element.fromToTiming.from.isAfter(now))
        .toList()
          ..sort((a, b) {
            return a.fromToTiming.from.compareTo(b.fromToTiming.from);
          });
  }

  List<BusinessBooking> getUpcomingBookings() {
    final now = DateTime.now();
    return branchBookings
        .where((element) =>
            element.status.value == BusinessBookingStatus.accepted &&
            element.fromToTiming.from.isAfter(now))
        .toList()
          ..sort((a, b) {
            return a.fromToTiming.from.compareTo(b.fromToTiming.from);
          });
  }

  List<BusinessBooking> getUnratedBookings() {
    return myBookings
        .where((element) =>
            element.status.value == BusinessBookingStatus.finished &&
            (element.rating.bookingRatingPhase.value == BookingRatingPhase.notRated))
        .toList();
  }
}
