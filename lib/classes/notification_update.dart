import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

import '../fcm.dart';

///firebase notification update structure
class NotificationUpdate {
  final DocumentReference myDoc;
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final MessagOrUpdateType type;
  final Timestamp at;
  final bool viewed;

  NotificationUpdate({
    this.myDoc,
    this.data,
    this.title,
    this.description,
    this.type,
    this.at,
    this.viewed = false,
  });

  NotificationUpdate update({bool viewed}) {
    return NotificationUpdate(
      myDoc: myDoc,
      type: type,
      at: at,
      description: description,
      title: title,
      viewed: viewed ?? this.viewed,
      data: data,
    );
  }

  static NotificationUpdate fromSnapshot(DocumentSnapshot snap) {
    final j = snap.data();
    return NotificationUpdate(
      myDoc: snap.reference,
      title: j.remove("title"),
      description: j.remove("description"),
      type: EnumToString.fromString(
        MessagOrUpdateType.values,
        j.remove("type"),
      ),
      at: j.remove("at"),
      viewed: j.remove("viewed"),
      data: j,
    );
  }

  toMap() {
    return <String, dynamic>{
      "title": title,
      "description": description,
      "type": EnumToString.convertToString(type),
      "at": at.millisecondsSinceEpoch.toString(),
      "": viewed,
      ...data,
    };
  }
}
