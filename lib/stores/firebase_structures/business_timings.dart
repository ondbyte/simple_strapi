import 'dart:convert';

import 'package:bapp/config/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:bapp/helpers/extensions.dart';

class BusinessTimings {
  final allDayTimings = Observable(ObservableList<DayTiming>());

  Map<String, dynamic> toMap() {
    return allDayTimings.value.fold(
      {},
      (previousValue, dt) {
        previousValue.addAll({dt.dayName: dt.toMap()});
        return previousValue;
      },
    );
  }

  BusinessTimings.empty() {
    allDayTimings.value.addAll(kDays.map((e) => DayTiming({}, dayName: e)));
    _sort();
  }

  BusinessTimings.fromJson(Map<String, dynamic> j) {
    if (j != null) {
      j.forEach(
        (key, value) {
          allDayTimings.value.add(
            DayTiming(value, dayName: key),
          );
        },
      );
    }
    _sort();
  }

  _sort() {
    allDayTimings.value.sort(
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
    from = from;
    to = to;
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
    final now = DateTime.now();
    from = DateTime(now.year, now.month, now.day);
    to = from.add(const Duration(days: 1));
  }

  List<FromToTiming> splitInto({int stepMinutes}) {
    final step = Duration(minutes: stepMinutes);
    final list = <FromToTiming>[];
    while (true) {
      final f = from;
      final t = from.add(step);
      if (t.isBefore(to)) {
        list.add(FromToTiming.fromDates(from: f, to: t));
      } else {
        break;
      }
    }
    return list;
  }

  List<FromToTiming> punchHoles(List<FromToTiming> timings) {
    final list = <FromToTiming>[];
  }

  List<FromToTiming> punchHole(FromToTiming timing) {
    final list = <TimeOfDay>[];
    var _from = from.toTimeOfDay();
    var _to = to.toTimeOfDay();
    var _otherFrom = timing.from.toTimeOfDay();
    var _otherTo = timing.to.toTimeOfDay();
    if (_from.isSame(_otherFrom)) {
      if (_to.isSame(_otherTo)) {
        return [];
      }
      return [
        FromToTiming.fromDates(
            from: _otherTo.toDateAndTime(), to: _to.toDateAndTime())
      ];
    } else {
      if (_to.isSame(_otherTo)) {
        [
          FromToTiming.fromDates(
              from: _from.toDateAndTime(), to: _otherFrom.toDateAndTime())
        ];
      }
      return [
        FromToTiming.fromDates(
          from: _from.toDateAndTime(),
          to: _otherFrom.toDateAndTime(),
        ),
        FromToTiming.fromDates(
          from: _otherTo.toDateAndTime(),
          to: _to.toDateAndTime(),
        )
      ];
    }
  }
}
