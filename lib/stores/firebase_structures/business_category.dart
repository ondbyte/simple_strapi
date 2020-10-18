import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessCategory {
  final DocumentReference document;
  final String normalName;

  BusinessCategory({this.normalName, this.document});

  static BusinessCategory fromJson(Map<String, dynamic> j) {
    return BusinessCategory(
        normalName: j["normalName"] as String,
        document: j["document"] as DocumentReference);
  }

  Map<String, dynamic> toMap() {
    return {
      "normalName": normalName,
      "name": document,
    };
  }
}
