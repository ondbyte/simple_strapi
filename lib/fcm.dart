import 'dart:io';

import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:enum_to_string/enum_to_string.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobx/mobx.dart';
import 'package:notification_permissions/notification_permissions.dart';

import 'classes/firebase_structures/bapp_fcm_message.dart';
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
  late Function(BappFCMMessage) _bappMessagesListener;

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

  void init() {
    initForAndroid();
    initForIOS();
  }

  void initForAndroid() {
    if (Platform.isAndroid) {
      _init(FirebaseMessaging.instance);
    }
  }

  Future requestOnIOS() async {
    final granted = await FirebaseMessaging.instance.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );
    if (granted.authorizationStatus == AuthorizationStatus.authorized) {
      initForIOS();
    }
  }

  Future<bool> initForIOS() async {
    if (Platform.isIOS) {
      final _fcm = FirebaseMessaging.instance;
      if ((await NotificationPermissions.getNotificationPermissionStatus()) ==
          PermissionStatus.unknown) {
        return false;
      }
      if ((await NotificationPermissions.getNotificationPermissionStatus()) ==
          PermissionStatus.granted) {
        _init(_fcm);
      } else {
        return false;
      }
      return true;
    }
    return false;
  }

  Future onMessage(Map<String, dynamic> message) async {
    if (message.containsKey("data")) {
      print(message["data"]);
      var bappMessage;
      try {} catch (e) {
        Helper.bPrint(e.toString());
      }
    } else {
      Helper.bPrint("no data on message");
    }
  }

  void _init(FirebaseMessaging _fcm) async {
    if (isFcmInitialized) {
      return;
    }
    /* _fcm.configure(
      onBackgroundMessage:
          Platform.isAndroid ? myBackgroundMessageHandler : null,
      onLaunch: onMessage,
      onResume: onMessage,
      onMessage: onMessage,
    ); */
    isFcmInitialized = true;
    kNotifEnabled = true;
    print("FCM initialized for " + Platform.operatingSystem);
    Helper.bPrint("Getting FCM token");

    _fcm.onTokenRefresh.listen(onNewToken);
  }

  void onNewToken(String token) {
    if (fcmToken.value == token) {
      return;
    }
    fcmToken.value = token;
    print("fcmToken " + fcmToken.value);
  }

  ///cached messages
  List<BappFCMMessage> messageCache = [];
  void _deliverToListener(BappFCMMessage bappMessage) {
    ///as this is a singleton class, while this class is instantiated, the apps widget tree might not be built
    ///so wait and cache the FCM until there is a listener available
    if (_bappMessagesListener == null) {
      messageCache.add(bappMessage);
    } else {
      _bappMessagesListener(bappMessage);
    }
  }
}
