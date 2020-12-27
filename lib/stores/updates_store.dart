import 'package:bapp/classes/firebase_structures/bapp_fcm_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

class UpdatesStore {
  final updates = ObservableList<BappFCMMessage>();
  final news = ObservableList<BappFCMMessage>();
  int _page = 1;

  UpdatesStore();

  Future init() async {
    await getUpdates();
  }

  Future getUpdates({bool nextPage = false}) async {
    if (nextPage) {
      _page++;
    }
    FirebaseFirestore.instance
        .collection("updates")
        .orderBy("time", descending: true)
        .limit(16 * _page)
        .snapshots()
        .listen((snaps) {
      final _updates = <BappFCMMessage>[];
      if (snaps.docs.isNotEmpty) {
        snaps.docs.forEach((updateSnap) {
          _updates.add(BappFCMMessage.fromJson(j: updateSnap.data()));
        });
      }
      updates.clear();
      updates.addAll(_updates);
    });
  }
}
