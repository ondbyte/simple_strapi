import 'dart:io';

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

  bool _isFcmInitialized = false;

  BappFCM._once();

  void listenForStaffingAuthorizationOnce(Function(BappFCMMessage) fn,
      {Duration duration = const Duration(seconds: 60)}) {
    if (_staffingAuthorizationListener != null) {
      throw Exception("this should never be the case @BappFCM");
    }
    _staffingAuthorizationListener = fn;
    Future.delayed(duration, () {
      if (_staffingAuthorizationListener != null) {
        _staffingAuthorizationListener(null);
        _staffingAuthorizationListener = null;
      }
    });
  }

  void listenForBappMessages(Function(BappFCMMessage) fn) {
    _bappMessagesListener = fn;
  }

  initForAndroid() {
    if (!_isFcmInitialized) {
      if (Platform.isAndroid) {
        _init(FirebaseMessaging());
      }
    }
  }

  Future initForIOS() async {
    final _fcm = FirebaseMessaging();
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    _init(_fcm);
  }

  Future onMessage(Map<String, dynamic> message) async {
    if (message.containsKey("data")) {
      Helper.printLog("before bapp message");
      final bappMessage = BappFCMMessage.fromJson(message["data"]);
      Helper.printLog("after bapp message");
      if (bappMessage.type ==
              BappFCMMessageType.staffAuthorizationAskAcknowledge ||
          bappMessage.type == BappFCMMessageType.staffAuthorizationAskDeny) {
        Helper.printLog("authorization message");
        if (_staffingAuthorizationListener != null) {
          _staffingAuthorizationListener(bappMessage);
          _staffingAuthorizationListener = null;
        }
      } else if (_bappMessagesListener != null) {
        Helper.printLog("General message");
        _bappMessagesListener(bappMessage);
      }
    } else {
      Helper.printLog("no data on message");
    }
  }

  _init(FirebaseMessaging _fcm) {
    _fcm.configure(
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: onMessage,
      onResume: onMessage,
      onMessage: onMessage,
    );
    _fcm.onTokenRefresh.listen((event) {
      fcmToken.value = event;
      print("fcmToken " + fcmToken.value);
    });
    _isFcmInitialized = true;
    kNotifEnabled = true;
    print("FCM initialized for " + Platform.operatingSystem);
  }
}

class BappFCMMessage {
  BappFCMMessageType type;
  String title;
  String body;
  Map<String, String> data;

  ///international number
  String to;

  ///international number
  String frm;
  String click_action;
  BappFCMMessagePriority priority;

  BappFCMMessage(
      {this.title = "",
      this.body = "",
      this.type,
      this.data,
      this.frm = "",
      this.to = "",
      this.priority = BappFCMMessagePriority.high,
      this.click_action = "BAPP_NOTIFICATION_CLICK"}) {
    data?.remove("type");
    data?.remove("title");
    data?.remove("body");
    data?.remove("frm");
    data?.remove("to");
    data?.remove("priority");
    data?.remove("click_action");
  }

  BappFCMMessage.fromJson(Map<String, String> j) {
    type = EnumToString.fromString(BappFCMMessageType.values, j["type"]);
    title = j.remove("title");
    body = j.remove("body");
    frm = j.remove("frm");
    to = j.remove("to");
    priority = EnumToString.fromString(
      BappFCMMessagePriority.values,
      j.remove("priority"),
    );
    click_action = j.remove("click_action");
    data = j;
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
    };
    data?.forEach((key, value) {
      m.addAll({key: value});
    });
    return m;
  }
}

enum BappFCMMessageType {
  staffAuthorizationAsk,
  staffAuthorizationAskAcknowledge,
  staffAuthorizationAskDeny
}

enum BappFCMMessagePriority { high }
