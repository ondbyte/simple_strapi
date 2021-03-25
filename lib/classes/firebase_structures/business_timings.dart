/* import 'dart:convert';

import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';

class BusinessTimings {
  final allDayTimings = ObservableList<DayTiming>();

  Map<String, dynamic> toMap() {
    return allDayTimings.fold(
      {},
      (previousValue, dt) {
        previousValue.addAll({dt.dayName: dt.toMap()});
        return previousValue;
      },
    );
  }

  List<FromToTiming> getTodayTimings() {
    final today = DateFormat("EEEE").format(DateTime.now());
    return allDayTimings
        .firstWhere(
            (element) => element.dayName.toLowerCase() == today.toLowerCase())
        .timings
        .value;
  }

  List<FromToTiming> getForDay(DateTime day) {
    final todayName = DateFormat(DateFormat.WEEKDAY).format(day).toLowerCase();
    final todayTimings =
        allDayTimings.firstWhere((dt) => dt.dayName == todayName);
    return todayTimings.timings.value.toList();
  }

  BusinessTimings.empty() {
    allDayTimings.addAll(kDays.map((e) => DayTiming({}, dayName: e)));
    _sort();
  }

  BusinessTimings.fromJson(Map<String, dynamic> j) {
    if (j != null) {
      j.forEach(
        (key, value) {
          allDayTimings.add(
            DayTiming(value, dayName: key),
          );
        },
      );
    }
    _sort();
  }

  _sort() {
    allDayTimings.sort(
      (a, b) {
        final aa = kDays.indexOf(a.dayName);
        final bb = kDays.indexOf(b.dayName);
        if (aa > bb) {
          return 1;
        }
        return -1;
      },
    );
  }
}

class DayTiming {
  final String dayName;
  final enabled = Observable(false);
  final timings = Observable(ObservableList<FromToTiming>());

  DayTiming(Map<String, dynamic> data, {this.dayName}) {
    enabled.value = data["enabled"] ?? false;
    timings.value.addAll(_getDayTimings(j: data["timings"] ?? []));
  }

  toMap() {
    filterNull();
    return {
      "dayName": dayName,
      "enabled": enabled.value,
      "timings": timings.value.isEmpty
          ? []
          : timings.value.map((element) => element.toJson()).toList(),
    };
  }

  filterNull() {
    timings.value.removeWhere((element) => element == null);
  }

  List<FromToTiming> _getDayTimings({List j = const []}) {
    final List<FromToTiming> dayTimings = [];
    j.forEach(
      (element) {
        final FromToTiming fromTo = FromToTiming(element);
        dayTimings.add(fromTo);
      },
    );
    return dayTimings;
  }
}

class FromToTiming {
  DateTime from;
  DateTime to;

  FromToTiming(String data) {
    final j = json.decode(data);
    from = DateTime.parse(j[0]);
    to = DateTime.parse(j[1]);
  }

  FromToTiming.fromDates({DateTime from, DateTime to}) {
    this.from = from;
    this.to = to;
  }

  FromToTiming.fromTimeStamps({Timestamp from, Timestamp to}) {
    this.from = from.toDate();
    this.to = to.toDate();
  }

  String toJson() {
    return json.encode([
      from.toIso8601String(),
      to.toIso8601String(),
    ]);
  }

  FromToTiming.today() {
    _forDay(DateTime.now());
  }

  FromToTiming.forDay(DateTime day) {
    _forDay(day);
  }

  _forDay(DateTime day) {
    from = DateTime(day.year, day.month, day.day);
    to = from.add(const Duration(days: 1));
  }

  List<FromToTiming> splitInto({
    int stepMinutes,
    int durationPadding = 0,
  }) {
    final padding = Duration(minutes: durationPadding);
    final step = Duration(minutes: stepMinutes);
    final list = <FromToTiming>[];
    var shouldGoAhead = true;
    var f = from;
    var t = from.add(step);
    while (shouldGoAhead) {
      final end = t.toTimeOfDay();
      if ((end.isBefore(to.toTimeOfDay()) || end.isSame(to.toTimeOfDay())) &&
          !f.add(padding).toTimeOfDay().isAfter(to.toTimeOfDay())) {
        list.add(FromToTiming.fromDates(from: f, to: t));
      } else {
        shouldGoAhead = false;
      }
      f = f.add(step);
      t = t.add(step);
    }
    return list;
  }

  String format() {
    final _format = DateFormat("hh:mm a");
    return _format.format(from) + " to " + _format.format(to);
  }

  String formatFromWithDate() {
    final _format = DateFormat("dd MMM, hh:mm a");
    return _format.format(from);
  }

  String formatMinutes() {
    return inMinutes().toString() + " Minutes";
  }

  int inMinutes() {
    return to.difference(from).inMinutes;
  }
}
 */