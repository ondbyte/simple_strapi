
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

import '../fcm.dart';

///firebase notification update structure
class NotificationUpdate {
  String title;
  String description;
  String bookingRef;
  MessagOrUpdateType type;
  String fromToken;
  Timestamp at;
  bool viewed;
  String state;

  NotificationUpdate({
    this.state,
    this.title,
    this.description,
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
        EnumToString.fromString(MessagOrUpdateType.values, j["type"]);
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
      "at": at.millisecondsSinceEpoch.toString(),
      "fromToken": fromToken,
    };
  }
}
