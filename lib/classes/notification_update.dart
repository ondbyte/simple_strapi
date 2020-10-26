import 'dart:ui';

import 'package:bapp/config/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';

///firebase notification update structure
class NotificationUpdate {
  String title;
  String description;
  int orderId;
  NotificationUpdateType type;
  String fromToken;
  Timestamp at;
  bool viewed;
  String state;

  NotificationUpdate({
    this.state,
    this.title,
    this.description,
    this.orderId,
    this.type,
    this.at,
    this.viewed = false,
    this.fromToken,
  });

  NotificationUpdate.fromJson(Map<String, dynamic> j) {
    this.state = j["state"];
    this.title = j["title"];
    this.description = j["description"];
    this.type =
        EnumToString.fromString(NotificationUpdateType.values, j["type"]);
    this.orderId = j["orderId"] as int ?? -1;
    this.at = Timestamp.fromMillisecondsSinceEpoch(j["at"]);
    this.viewed = j["viewed"] as bool;
    this.fromToken = j["fromToken"] as String;
  }

  toStringMap() {
    return <String, String>{
      "state": state.toString(),
      "title": title,
      "description": description,
      "type": EnumToString.convertToString(type),
      "orderId": orderId.toString(),
      "at": at.millisecondsSinceEpoch.toString(),
      "fromToken": fromToken,
    };
  }
}

enum NotificationUpdateType { orderUpdate, news, staffing }
