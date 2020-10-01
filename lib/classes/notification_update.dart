
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

  NotificationUpdate(this.title, this.description, this.html, this.orderId, this.type,this.at);

  NotificationUpdate.fromJson(Map<String,dynamic> j){
    this.title = j["title"];
    this.html = j["html"];
    this.description = j["description"];
    this.type = EnumToString.fromString(NotificationUpdateType.values, j["type"]);
    this.orderId = j["orderId"] as int;
    this.at = j["at"] as Timestamp;
  }

}
enum NotificationUpdateType{
  orderUpdate,
  news
}