import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

export 'package:bapp/widgets/app/bapp_navigator_widget.dart';

extension DateTimeOfDay on TimeOfDay {
  ///returns a [DateTime] from the current [TimeOfDay], [year] [month] [day] respects the Unix Epoch but can be altered with the optional parameters
  DateTime toDateAndTime({
    int year = 1970,
    int month = 01,
    int day = 01,
  }) {
    return DateTime(year, month, day, this.hour, this.minute);
  }

  ///returns a [String] formatted with am or pm, default is [format] example : 02:05 PM
  String toStringWithAmOrPm({String format = "hh:mm a"}) {
    return this.toDateAndTime().toStringWithAmOrPm(format: format);
  }

  bool isPM() {
    return this.period == DayPeriod.pm;
  }

  bool isAM() {
    return this.period == DayPeriod.am;
  }

  bool isBefore(TimeOfDay timeOfDay) {
    return compareTo(timeOfDay) == -1;
  }

  bool isSame(TimeOfDay timeOfDay) {
    return compareTo(timeOfDay) == 0;
  }

  bool isAfter(TimeOfDay timeOfDay) {
    return compareTo(timeOfDay) == 1;
  }

  int compareTo(TimeOfDay timeOfDay) {
    final other = timeOfDay.hour * 60 + timeOfDay.minute;
    final thiss = this.hour * 60 + this.minute;
    if (thiss < other) {
      return -1;
    } else if (thiss == other) {
      return 0;
    } else {
      return 1;
    }
  }
}

extension TimeOfDayDateAndTime on DateTime {
  ///returns a [TimeOfDay] using this time and date's hour and minute
  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: this.hour, minute: this.minute);
  }

  ///returns a [String] formatted with am or pm, default is [format] example : 02:05 PM
  String toStringWithAmOrPm({String format = "hh:mm a"}) {
    final _format = DateFormat(format);
    return _format.format(this);
  }

  bool isPM() {
    return toTimeOfDay().isPM();
  }

  bool isAM() {
    return toTimeOfDay().isAM();
  }

  ///returns day name like "Sunday"
  String dayName() {
    final _format = DateFormat("EEEE");
    return _format.format(this);
  }

  ///returns short day name like "Sun"
  String shortDayName() {
    final _format = DateFormat("EEE");
    return _format.format(this);
  }

/*   Timestamp toTimeStamp() {
    return Timestamp.fromDate(this);
  } */

  bool isDay(DateTime dt) {
    return day == dt.day && month == dt.month;
  }

  DateTime toDay(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day, hour, minute);
  }
}

extension RemoveCopies<T> on List<T> {
  void removeSuccessiveCopies(bool Function(T a, T b) fn) {
    for (var t = 0; t < this.length - 1; t++) {
      if (fn(this[t], this[t + 1])) {
        removeAt(t + 1);
        remove(t);
      }
    }
  }
}

extension CautiousCompleter on Completer {
  bool cautiousComplete<T>(T value) {
    if (isCompleted) {
      return false;
    }
    complete(value);
    return true;
  }
}
