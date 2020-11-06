import 'dart:convert';
import 'dart:io';

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
      final bappMessage = BappFCMMessage.fromStringData(message["data"]);
      if (bappMessage.type ==
              BappFCMMessageType.staffAuthorizationAskAcknowledge ||
          bappMessage.type == BappFCMMessageType.staffAuthorizationAskDeny) {
        if (_staffingAuthorizationListener != null) {
          _staffingAuthorizationListener(bappMessage);
          _staffingAuthorizationListener = null;
        }
      } else if (_bappMessagesListener != null) {
        _bappMessagesListener(bappMessage);
      }
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
  final BappFCMMessageType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;

  ///international number
  final String to;

  ///international number
  final String frm;
  final String click_action;
  final BappFCMMessagePriority priority;

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

  static BappFCMMessage fromStringData(String s) {
    final data = jsonDecode(s);
    return BappFCMMessage(
        type: EnumToString.fromString(BappFCMMessageType.values, data["type"]),
        title: data["title"],
        body: data["body"],
        frm: data["frm"],
        to: data["to"],
        data: data,
        priority: EnumToString.fromString(
          BappFCMMessagePriority.values,
          data["priority"],
        ),
        click_action: data["click_action"]);
  }

  toMap() {
    return {
      "type": EnumToString.convertToString(type),
      "title": title,
      "body": body,
      "frm": frm,
      "to": to,
      "data": data,
      "priority": EnumToString.convertToString(priority),
      "click_action": click_action,
    };
  }
}

enum BappFCMMessageType {
  staffAuthorizationAsk,
  staffAuthorizationAskAcknowledge,
  staffAuthorizationAskDeny
}

enum BappFCMMessagePriority { high }
