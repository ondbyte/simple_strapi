import 'package:bapp/config/config_data_types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

class BappFCMMessage {
  final MessageOrUpdateType type;
  final String title;
  final String body;

  ///international number
  final String to;

  ///international number
  final String frm;
  final String click_action;
  final BappFCMMessagePriority priority;
  final Map<String, dynamic> data;
  final UserType forUserType;
  final DateTime time;
  final bool read;
  DocumentReference myDoc;

  BappFCMMessage({
    this.title = "",
    this.body = "",
    this.type,
    this.data=const {},
    this.frm = "",
    this.to = "",
    this.priority = BappFCMMessagePriority.high,
    this.click_action = "BAPP_NOTIFICATION_CLICK",
    this.forUserType,
    this.time,
    this.read = false,
    this.myDoc
  });

  static BappFCMMessage fromSnap(DocumentSnapshot snap){
    return fromJson(j:snap.data(),myDoc: snap.reference);
  }

  static BappFCMMessage fromJson({Map<String, dynamic> j,DocumentReference myDoc}) {
    return BappFCMMessage(
      type: EnumToString.fromString(MessageOrUpdateType.values, j["type"]),
      title: j.remove("title"),
      body: j.remove("body"),
      frm: j.remove("frm"),
      to: j.remove("to"),
      priority: EnumToString.fromString(
        BappFCMMessagePriority.values,
        j.remove("priority"),
      ),
      click_action: j.remove("click_action"),
      time: () {
        final d = j.remove("time");
        if(myDoc!=null){
          return d != null ? (d as Timestamp).toDate() : null;
        } else {
          return Timestamp.fromMillisecondsSinceEpoch(int.parse(d));
        }
      }(),
        read: (){
          final d = j.remove("read");
          if(d is String){
            return "true"==d.trim();
          }
          return d as bool;
        }(),
      data: Map.castFrom(j),
      myDoc: myDoc
    );
  }

  Map<String, dynamic> toStringMap() {
    return _toMap<String>();
  }

  Map<String, dynamic> toMap(){
    return _toMap<dynamic>();
  }

  Map<String,T> _toMap<T>(){
    final isString = T is String;

    final m = {
      "type": EnumToString.convertToString(type),
      "title": title,
      "body": body,
      "frm": frm,
      "to": to,
      "priority": EnumToString.convertToString(priority),
      "click_action": click_action,
      "time": isString?time.millisecondsSinceEpoch.toString():time,
      "read":isString?read.toString():read,
    };
    if(data!=null){
      data.forEach((key, value) {
        m.addAll({key: value});
      });
    }
    return m;
  }

  Future markRead() async {
    final map = toMap();
    map.update("read", (value) => true,ifAbsent: ()=>true);
    await myDoc?.set(map);
  }
}


enum MessageOrUpdateType { reminder, bookingUpdate, bookingRating, news }

enum BappFCMMessagePriority { high }