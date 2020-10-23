import 'package:bapp/config/constants.dart';
import 'package:bapp/stores/firebase_structures/business_branch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

class BusinessHolidays {
  final String myCollection;
  final all = ObservableList<BusinesssHoliday>();

  BusinessHolidays({this.myCollection}) {
    _getHolidays(myCollection);
  }

  Future _getHolidays(String cr) async {
    if (cr == null) {
      return;
    }
    final snaps = await FirebaseFirestore.instance.collection(cr).get();
    if (snaps.docs.isNotEmpty) {
      all.addAll(
          snaps.docs.toList().map((e) => BusinesssHoliday.fromJson(e.data())));
    }
  }

  Future addHoliday(
      {String name,
      String type,
      String details,
      List<DateTime> fromToDate}) async {
    final doc =
        FirebaseFirestore.instance.collection(myCollection).doc(kUUIDGen.v1());
    final holiday = BusinesssHoliday(fromToDate, name, type, details, doc);
    all.add(holiday);
    await holiday.saveHoliday();
  }

  Future removeHoliday(BusinesssHoliday holiday) async {
    all.remove(holiday);
    await holiday.delete();
  }
}

class BusinesssHoliday {
  final List<DateTime> dates;
  final String name;
  final String type;
  final String details;
  final DocumentReference myDoc;
  final enabled = Observable(false);

  BusinesssHoliday(
    this.dates,
    this.name,
    this.type,
    this.details,
    this.myDoc,
  ) {
    _setUpReactions();
  }

  List<ReactionDisposer> _disposers = [];
  _setUpReactions() {
    _disposers.add(
      reaction((_) => enabled.value, (_) async {
        await myDoc.update({"enabled": enabled.value});
      }),
    );
  }

  static fromJson(Map<String, dynamic> j) {
    return BusinesssHoliday(
      (j["dates"] as List).map((e) => e.toDate() as DateTime).toList(),
      j["name"],
      j["type"],
      j["details"],
      j["myDoc"],
    )..enabled.value = j["enabled"];
  }

  Future saveHoliday() async {
    final map = toMap();
    await myDoc.set(map);
  }

  Future delete() async {
    await myDoc.delete();
  }

  toMap() {
    return {
      "dates": dates.map((e) => Timestamp.fromDate(e)).toList(),
      "name": name,
      "type": type,
      "details": details,
      "myDoc": myDoc,
      "enabled": enabled.value
    };
  }
}
