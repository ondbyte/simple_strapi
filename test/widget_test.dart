// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bapp/classes/firebase_structures/business_timings.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bapp/main.dart';

void main() {
  test("testing time arrange",(){
    final wh = [
      FromToTiming.fromDates(from: DateTime(2020,11,1,9),to: DateTime(2020,11,1,13)),
      FromToTiming.fromDates(from: DateTime(2020,11,1,14),to: DateTime(2020,11,1,18)),
    ];
    final buzy = [
      FromToTiming.fromDates(from: DateTime(2020,11,1,10),to: DateTime(2020,11,1,11)),
      FromToTiming.fromDates(from: DateTime(2020,11,1,12),to: DateTime(2020,11,1,13)),
    ];
  });
}
