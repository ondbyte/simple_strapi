import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

class BusinessTimings {
  final DocumentReference myDoc;
  final allDayTimings = Observable(ObservableList<DayTiming>());

  BusinessTimings({this.myDoc}) {
    _getTimings(myDoc);
  }

  Future saveTimings() async {
    await myDoc.set(toMap());
  }

  Map<String, dynamic> toMap() {
    return allDayTimings.value.fold(
      {},
      (previousValue, dt) {
        previousValue.addAll({dt.dayName: dt.toMap()});
        return previousValue;
      },
    );
  }

  Future _getTimings(DocumentReference myDoc) async {
    if (myDoc == null) {
      return;
    }
    final snap = await myDoc.get();
    if (snap.exists) {
      final data = snap.data();
      data.forEach(
        (key, value) {
          allDayTimings.value.add(
            DayTiming(value, dayName: key),
          );
        },
      );
    }
    final dt = ["sunday","monday","tuesday","wednesday","thursday","friday","saturday"];
    dt.forEach((day) {
      allDayTimings.value.any((element) => element.dayName.)
    });
    allDayTimings.value.addAll(dt.map((e) => DayTiming([],dayName: e)));
  }
}

class DayTiming {
  final String dayName;
  final enabled = Observable(false);
  final timings = Observable(ObservableList<FromToTiming>());

  DayTiming(List<dynamic> data, {this.dayName}) {
    timings.value.addAll(_getDayTimings(data));
  }

  toMap() {
    return {
      "dayName": dayName,
      "enabled":enabled.value,
      "timings": timings.value.map((element) => element.toList()),
    };
  }

  List<FromToTiming> _getDayTimings(List j) {
    final List<FromToTiming> dayTimings = [];
    j.forEach(
      (element) {
        final List<Timestamp> times = List.castFrom(element);
        final FromToTiming fromTo =
            FromToTiming(from: times.first.toDate(), to: times.last.toDate());
        dayTimings.add(fromTo);
      },
    );
    return dayTimings;
  }
}

class FromToTiming {
  final DateTime from;
  final DateTime to;

  FromToTiming({this.from, this.to});

  List<Timestamp> toList() {
    return [
      Timestamp.fromDate(from),
      Timestamp.fromDate(to),
    ];
  }
}
