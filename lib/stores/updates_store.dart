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
  final _fireStore = FirebaseFirestore.instance;
  @observable
  ObservableMap<String,NotificationUpdate> updates = ObservableMap();
  @observable
  ObservableMap<String,NotificationUpdate> news = ObservableMap();
  @observable
  ObservableMap<String,NotificationUpdate> viewed = ObservableMap();

  Future init(AuthStore as) async {
    this._authStore = as;
    if (_authStore.user == null) {
      throw FlutterError("this should never be the case @updates_store");
    }
    await getUpdates();
  }

  @action
  Future setViewedForUpdate(NotificationUpdate update) async {
    if (_authStore.user == null) {
      return;
    }
    await _fireStore.collection("users/${_authStore.user.uid}/updates/${update.id}").doc().update({
      "viewed": true
    });
  }

  @action
  Future getUpdates({DateTime dt}) async {
    final dateTime = dt ?? DateTime.now();
    if (_authStore.user == null) {
      return;
    }
    final updatesCollection =
        _fireStore.collection("users/${_authStore.user.uid}/updates");
    final updatesQuery = updatesCollection.where(
      "at",
      isLessThan: Timestamp.fromDate(dateTime),
      isGreaterThan: Timestamp.fromDate(
        dateTime.subtract(
          const Duration(days: 7),
        ),
      ),
    );
    final snaps = await updatesQuery.get();
    print(snaps.docs);
    final allUpdates = snaps.docs.map(
      (e) => NotificationUpdate.fromJson(e.id,e.data()),
    );
    _segregate(allUpdates.toList());
  }

  ///segregate news/viewed
  void _segregate(List<NotificationUpdate> allUpdates){
    allUpdates.forEach(
          (element) {
        if (element.viewed) {
          viewed[element.id]=element;
        } else {
          if (element.type == NotificationUpdateType.news) {
            news[element.id]=element;
          } else {
            updates[element.id]=element;
          }
        }
      },
    );
  }
}
