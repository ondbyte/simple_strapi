import 'package:bapp/config/config_data_types.dart';
import 'package:enum_to_string/enum_to_string.dart';

class BappFCMMessage {
  final MessagOrUpdateType type;
  final String title;
  final String body;

  ///international number
  final String to;

  ///international number
  final String frm;
  final String click_action;
  final BappFCMMessagePriority priority;
  final Map<String, String> data;
  final UserType forUserType;
  final DateTime time;

  BappFCMMessage({
    this.title = "",
    this.body = "",
    this.type,
    this.data,
    this.frm = "",
    this.to = "",
    this.priority = BappFCMMessagePriority.high,
    this.click_action = "BAPP_NOTIFICATION_CLICK",
    this.forUserType,
    this.time,
  });

  static BappFCMMessage fromJson({Map<String, String> j}) {
    return BappFCMMessage(
      type: EnumToString.fromString(MessagOrUpdateType.values, j["type"]),
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
        return d != null ? DateTime.parse(d) : null;
      }(),
      data: j,
    );
  }


  Map<String, String> toMap() {
    final m = {
      "type": EnumToString.convertToString(type),
      "title": title,
      "body": body,
      "frm": frm,
      "to": to,
      "priority": EnumToString.convertToString(priority),
      "click_action": click_action,
      "time":time.millisecondsSinceEpoch.toString(),
    };
    data?.forEach((key, value) {
      m.addAll({key: value});
    });
    return m;
  }
}

enum MessagOrUpdateType { reminder, bookingUpdate, bookingRating, news }

enum BappFCMMessagePriority { high }
