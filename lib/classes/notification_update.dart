
import 'dart:ui';

import 'package:bapp/config/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';

///firebase notification update structure
class NotificationUpdate{
  String title;
  String description;
  String html;
  int orderId;
  NotificationUpdateType type;
  Timestamp at;
  bool viewed;
  String id;
  Color myColor;

  NotificationUpdate(this.id,this.title, this.description, this.html, this.orderId, this.type,this.at,this.viewed,);

  NotificationUpdate.fromJson(String id,Map<String,dynamic> j){
    this.id = id;
    this.title = j["title"];
    this.html = j["html"];
    this.description = j["description"];
    this.type = EnumToString.fromString(NotificationUpdateType.values, j["type"]);
    this.orderId = j["orderId"] as int;
    this.at = j["at"] as Timestamp;
    this.viewed = j["viewed"] as bool;
    this.myColor = CardsColor.next();
  }

}
enum NotificationUpdateType{
  orderUpdate,
  news
}