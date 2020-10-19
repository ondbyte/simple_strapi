import 'package:bapp/stores/firebase_structures/business_branch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

class BusinessHolidays {
  final String myCollection;
  final all = Observable(ObservableMap<String, List<DateTime>>());

  BusinessHolidays({this.myCollection}) {
    _getHolidays(myCollection);
  }

  Future _getHolidays(String cr) async {
    if (cr == null) {
      return;
    }
    final snaps = await FirebaseFirestore.instance.collection(cr).get();
    if (snaps.docs.isNotEmpty) {
      all.value =
          snaps.docs.fold<Map<String, List<DateTime>>>({}, (previousValue, e) {
        previousValue.addAll({e.id: _getDates(e.data())});
        return previousValue;
      });
    }
  }

  List<DateTime> _getDates(Map j) {
    return List.castFrom(j["all"]).map((e) => (e as Timestamp).toDate());
  }

  Future addHoliday({String name, List<DateTime> fromToDate}) async {
    await FirebaseFirestore.instance
        .collection(myCollection)
        .doc(name)
        .set({"all": fromToDate.map((e) => Timestamp.fromDate(e))});
  }
}
