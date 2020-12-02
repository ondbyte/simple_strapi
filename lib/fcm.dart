import 'dart:io';

import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobx/mobx.dart';

import 'config/constants.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
    print(data);
  }

  if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];
    print(notification);
  }
}

class BappFCM {
  static final BappFCM _bappFCM = BappFCM._once();
  final fcmToken = Observable("");
  Function(BappFCMMessage) _staffingAuthorizationListener;
  Function(BappFCMMessage) _bappMessagesListener;

  factory BappFCM() {
    return _bappFCM;
  }

  bool isFcmInitialized = false;

  BappFCM._once();

  void listenForBappMessages(Function(BappFCMMessage) fn) {
    _bappMessagesListener = fn;

    ///deliver cached messages when listener is added
    if (messageCache.isNotEmpty) {
      final c = messageCache;
      messageCache.clear();
      c.forEach((element) {
        _deliverToListener(element);
      });
    }
  }

  initForAndroid() {
    if (!isFcmInitialized) {
      if (Platform.isAndroid) {
        _init(FirebaseMessaging());
      }
    }
  }

  Future<bool> initForIOS() async {
    if (Platform.isIOS) {
      final _fcm = FirebaseMessaging();
      final enabled = await _fcm.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false),
      );
      if (enabled) {
        _init(_fcm);
        _fcm.setAutoInitEnabled(true);
        isFcmInitialized = true;
      } else {
        if (!isFcmInitialized) {
          _fcm.onIosSettingsRegistered.listen(
            (event) {
              initForIOS();
            },
          );
        }
      }
      return enabled;
    }
    return false;
  }

  Future onMessage(Map<String, dynamic> message) async {
    if (message.containsKey("data")) {
      print(message["data"]);
      var bappMessage;
      try {
        bappMessage = BappFCMMessage.fromJson(j: Map.castFrom(message["data"]));
        _deliverToListener(bappMessage);
      } catch (e) {
        Helper.printLog(e.toString());
      }
    } else {
      Helper.printLog("no data on message");
    }
  }

  _init(FirebaseMessaging _fcm) {
    _fcm.configure(
      onBackgroundMessage:
          Platform.isAndroid ? myBackgroundMessageHandler : null,
      onLaunch: onMessage,
      onResume: onMessage,
      onMessage: onMessage,
    );
    _fcm.onTokenRefresh.listen((event) {
      fcmToken.value = event;
      print("fcmToken " + fcmToken.value);
    });
    isFcmInitialized = true;
    kNotifEnabled = true;
    print("FCM initialized for " + Platform.operatingSystem);
  }

  ///cached messages
  List<BappFCMMessage> messageCache = [];
  void _deliverToListener([BappFCMMessage bappMessage]) {
    ///as this is a singleton class, while this class is instantiated, the apps widget tree might not be built
    ///so wait and cache the FCM until there is a listener available
    if (_bappMessagesListener == null) {
      messageCache.add(bappMessage);
    } else {
      _bappMessagesListener(bappMessage);
    }
  }
}

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
  final DateTime remindTime;
  final Map<String, String> data;
  final UserType forUserType;

  BappFCMMessage({
    this.title = "",
    this.body = "",
    this.type,
    this.data,
    this.frm = "",
    this.to = "",
    this.remindTime,
    this.priority = BappFCMMessagePriority.high,
    this.click_action = "BAPP_NOTIFICATION_CLICK",
    this.forUserType,
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
      data: j,
    );
  }

  BappFCMMessage update({DateTime remindTime,String to}) {
    return BappFCMMessage(
      type: type,
      title: title,
      to: to??this.to,
      frm: frm,
      data: data,
      priority: priority,
      body: body,
      click_action: click_action,
      remindTime: remindTime??this.remindTime,
    );
  }

  Map<String, String> toMap() {
    if (type == MessagOrUpdateType.reminder) {
      assert(remindTime != null, "reminder message must have a reminding time");
    }
    final m = {
      "type": EnumToString.convertToString(type),
      "title": title,
      "body": body,
      "frm": frm,
      "to": to,
      "priority": EnumToString.convertToString(priority),
      "click_action": click_action,
      "remindTime": remindTime != null ? remindTime.toIso8601String() : "",
    };
    data?.forEach((key, value) {
      m.addAll({key: value});
    });
    return m;
  }
}

enum MessagOrUpdateType {
  reminder,
  bookingUpdate,
  bookingRating,
  news
}

enum BappFCMMessagePriority { high }
