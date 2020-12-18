import 'dart:io';

import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobx/mobx.dart';

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

  void init() {
    initForAndroid();
    final _fcm = FirebaseMessaging();
    _fcm.onTokenRefresh.listen(
      (event) {
        Helper.printLog("YAAAAA");
      },
    );
  }

  void initForAndroid() {
    if (!isFcmInitialized) {
      if (Platform.isAndroid) {
        _init(FirebaseMessaging());
      }
    }
  }

  Future<bool> initForIOS() async {
    Helper.printLog("INIT for IOOOS");
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

  void _init(FirebaseMessaging _fcm) {
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
