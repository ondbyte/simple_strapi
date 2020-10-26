import 'dart:convert';
import 'dart:io';

import 'package:bapp/classes/notification_update.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'config/constants.dart';
import 'package:mobx/mobx.dart';
import 'package:http/http.dart' as http;

Function({dynamic data, dynamic notif}) kFCMListener;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (kFCMListener != null) {
    if (message.containsKey('data')) {
      final dynamic data = message['data'];
      kFCMListener(data: data);
    }

    if (message.containsKey('notification')) {
      final dynamic notification = message['notification'];
      kFCMListener(notif: notification);
    }
  }
}

class BappFCM {
  static final BappFCM _bappFCM = BappFCM._once();
  final fcmToken = Observable("");

  factory BappFCM() {
    return _bappFCM;
  }

  bool _isFcmInitialized = false;

  BappFCM._once();

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

  _init(FirebaseMessaging _fcm) {
    _fcm.configure(
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> lMessage) async {
        //print("[ON_LAUNCH] " + lMessage.toString());
        if (kFCMListener != null) {
          kFCMListener(data: lMessage["data"], notif: lMessage["notification"]);
        }
      },
      onResume: (Map<String, dynamic> rMessage) async {
        //print("[ON_RESUME] " + rMessage.toString());
        if (kFCMListener != null) {
          kFCMListener(data: rMessage["data"], notif: rMessage["notification"]);
        }
      },
      onMessage: (Map<String, dynamic> message) async {
        //print("[ON_MESSAGE] " + message.toString());
        if (kFCMListener != null) {
          kFCMListener(data: message["data"], notif: message["notification"]);
        }
      },
    );
    _fcm.onTokenRefresh.listen((event) {
      fcmToken.value = event;
      print("fcmToken " + fcmToken.value);
    });
    _isFcmInitialized = true;
    kNotifEnabled = true;
    print("FCM initialized for " + Platform.operatingSystem);
  }

  ///this is sensitive data
  ///initially we are hardcoding to the app
  ///should be removed in future
  final _fcmSkey =
      "AAAAtsRvSvM:APA91bFjKAqKAtMFQGMkRIevlHmsoSO-2oNOicRcRPJotvLLDvM0lmfA1R2kx2AOhRDbD9cSohmbo8QOUwZ_IOMirAbOL0Xu2XY2FVY9h9j_6X-vUwf6-L44ydHW5I3oBe1Ih056VUe8";

  send({NotificationUpdate notificationUpdate, String toFcmToken}) async {
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$_fcmSkey',
      },
      body: jsonEncode(
        <String, dynamic>{
          "notification": <String, dynamic>{
            "body": "this is body",
            "title": "this is a title",
            "click_action": "BAPP_NOTIFICATION_CLICK",
          },
          "priority": "high",
          "data": <String, dynamic>{
            "click_action": "BAPP_NOTIFICATION_CLICK",
            ...notificationUpdate.toStringMap(),
          },
          "to": toFcmToken
        },
      ),
    );
  }
}
