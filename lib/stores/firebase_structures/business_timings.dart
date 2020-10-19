import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

class BusinessTimings {
  final DocumentReference myDoc;
  final sundayTiming = Observable(ObservableList<FromToTiming>());
  final mondayTiming = Observable(ObservableList<FromToTiming>());
  final tuesdayTiming = Observable(ObservableList<FromToTiming>());
  final wednesdayTiming = Observable(ObservableList<FromToTiming>());
  final thursdayTiming = Observable(ObservableList<FromToTiming>());
  final fridayTiming = Observable(ObservableList<FromToTiming>());
  final saturdayTiming = Observable(ObservableList<FromToTiming>());

  BusinessTimings({this.myDoc}) {
    _getTimings(myDoc);
  }

  Future saveTimings() async {
    await myDoc.set(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      "sundayTiming": sundayTiming.value.map((element) => element.toList()),
      "mondayTiming": mondayTiming.value.map((element) => element.toList()),
      "tuesdayTiming": tuesdayTiming.value.map((element) => element.toList()),
      "wednesdayTiming":
          wednesdayTiming.value.map((element) => element.toList()),
      "thursdayTiming": thursdayTiming.value.map((element) => element.toList()),
      "fridayTiming": fridayTiming.value.map((element) => element.toList()),
      "saturdayTiming": saturdayTiming.value.map((element) => element.toList()),
    };
  }

  Future _getTimings(DocumentReference myDoc) async {
    if (myDoc == null) {
      return;
    }
    final snap = await myDoc.get();
    if (snap.exists) {
      final data = snap.data();
      sundayTiming.value = _getDayTimings(data["sundayTiming"]);
      mondayTiming.value = _getDayTimings(data["mondayTiming"]);
      tuesdayTiming.value = _getDayTimings(data["tuesdayTiming"]);
      wednesdayTiming.value = _getDayTimings(data["wednesdayTiming"]);
      thursdayTiming.value = _getDayTimings(data["thursdayTiming"]);
      fridayTiming.value = _getDayTimings(data["fridayTiming"]);
      saturdayTiming.value = _getDayTimings(data["saturdayTiming"]);
    }
  }

  List<FromToTiming> _getDayTimings(List j) {
    final List<FromToTiming> dayTimings = [];
    j.forEach(
      (element) {
        final List<Timestamp> times = List.castFrom(element);
        final FromToTiming fromTo =
            FromToTiming(times.first.toDate(), times.last.toDate());
        dayTimings.add(fromTo);
      },
    );
    return dayTimings;
  }
}

class FromToTiming {
  final DateTime from;
  final DateTime to;

  FromToTiming(this.from, this.to);

  List<Timestamp> toList() {
    return [
      Timestamp.fromDate(from),
      Timestamp.fromDate(to),
    ];
  }
}
