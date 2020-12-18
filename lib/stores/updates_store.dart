import 'package:bapp/classes/firebase_structures/bapp_fcm_message.dart';
import 'package:bapp/classes/notification_update.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

class UpdatesStore {
  final updates = ObservableList<BappFCMMessage>();
  final news = ObservableList<BappFCMMessage>();
  DateTime fromDay;

  UpdatesStore();

  Future init() async {
    final now = DateTime.now();
    fromDay = DateTime(now.year, now.month, now.day, 0, 0);
    await _getUpdates();
  }

  Future _getUpdates({bool nextPage = false}) async {
    if (nextPage) {
      fromDay = fromDay.add(const Duration(days: 1));
    }
    FirebaseFirestore.instance
        .collection("updates")
        .where("at", isGreaterThan: fromDay.toTimeStamp(),
    );
  }
}
