import 'package:bapp/classes/notification_update.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

part 'updates_store.g.dart';

class UpdatesStore = _UpdatesStore with _$UpdatesStore;

abstract class _UpdatesStore with Store {
  AuthStore _authStore;
  final ObservableList<NotificationUpdate> updates = ObservableList();
  final ObservableList<NotificationUpdate> news = ObservableList();
  final _fireStore = FirebaseFirestore.instance;

  Future init(AuthStore as) async {
    this._authStore = as;
    if (_authStore.user == null) {
      throw FlutterError("this should never be the case @updates_store");
    }
    await getUpdates();
  }

  @observable
  Future getUpdates({DateTime dt}) async {
    final dateTime = dt ?? DateTime.now();
    if (_authStore.user == null) {
      return;
    }
    final updatesCollection = _fireStore.collection("updates");
    final updatesQuery = updatesCollection.where(
      "at",
      isLessThan: Timestamp.fromDate(dateTime),
      isGreaterThan: dateTime.subtract(
        const Duration(days: 7),
      ),
    );
    final snaps = await updatesQuery.get();
    print(snaps.docs);
    final allUpdates = snaps.docs.map(
      (e) => NotificationUpdate.fromJson(e.data()),
    );

    ///segregate news
    allUpdates.forEach(
      (element) {
        if (element.type == NotificationUpdateType.news) {
          news.add(element);
        } else {
          updates.add(element);
        }
      },
    );
  }
}
