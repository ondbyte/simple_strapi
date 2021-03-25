/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

import 'business_details.dart';

class BusinessHolidays {
  final BusinessDetails business;
  final all = ObservableList<BusinesssHoliday>();

  BusinessHolidays.empty({required this.business});

  BusinessHolidays.fromJsonList(List<dynamic> l, {required this.business}) {
    l.forEach((element) {
      all.add(BusinesssHoliday.fromJson(element));
    });
  }

  toList() {
    final l = [];
    all.forEach((element) {
      l.add(element.toMap());
    });
    return l;
  }

  Future addHoliday(
      {String? name,
      String? type,
      String? details,
      List<DateTime>? fromToDate}) async {
    final holiday = BusinesssHoliday(
      dates: fromToDate,
      name: name,
      type: type,
      details: details,
    );
    all.add(holiday);
    await save();
  }

  Future save() async {
    final list = all.fold<List>([], (previousValue, h) {
      previousValue.add(h.toMap());
      return previousValue;
    });
    await business.myDoc.value.update({"businessHolidays": list});
    await business.selectedBranch.value.myDoc.value
        .update({"businessHolidays": list});
  }

  Future removeHoliday(BusinesssHoliday holiday) async {
    all.remove(holiday);
    await save();
  }

  Map<DateTime, List> holidaysForBappCalender() {
    final map = <DateTime, List>{};
    all.forEach((element) {
      map.addAll(element.holidaysForBappCalender());
    });
    return map;
  }
}

class BusinesssHoliday {
  final List<DateTime>? dates;
  final String? name;
  final String? type;
  final String? details;
  final enabled = Observable(false);

  BusinesssHoliday({
    this.dates,
    this.name,
    this.type,
    this.details,
  });

  static fromJson(Map<String, dynamic> j) {
    return BusinesssHoliday(
      dates: (j["dates"] as List).map((e) => e.toDate() as DateTime).toList(),
      name: j["name"],
      type: j["type"],
      details: j["details"],
    )..enabled.value = j["enabled"];
  }

  toMap() {
    return {
      "dates": dates?.map((e) => Timestamp.fromDate(e)).toList(),
      "name": name,
      "type": type,
      "details": details,
      "enabled": enabled.value
    };
  }

  Map<DateTime, List> holidaysForBappCalender() {
    final map = <DateTime, List>{};
    dates?.forEach((element) {
      map.addAll({
        element: [type]
      });
    });
    return map;
  }
}
 */