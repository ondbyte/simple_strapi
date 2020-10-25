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
