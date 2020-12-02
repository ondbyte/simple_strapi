import 'package:bapp/classes/notification_update.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

import '../fcm.dart';

part 'updates_store.g.dart';

class UpdatesStore = _UpdatesStore with _$UpdatesStore;

abstract class _UpdatesStore with Store {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  @observable
  ObservableMap<String, NotificationUpdate> updates = ObservableMap();
  @observable
  ObservableMap<String, NotificationUpdate> news = ObservableMap();
  @observable
  ObservableMap<String, NotificationUpdate> viewed = ObservableMap();
  @observable
  User _user;

  Future init(BuildContext context) async {
    if (_auth.currentUser == null) {
      throw FlutterError("this should never be the case @updates_store");
    }
    _auth.userChanges().listen((u) {
      _user = u;
    });

    ///get updates on app start
    await getUpdates();
  }

  @action
  Future remove(NotificationUpdate u) async {
    if (u.type == MessagOrUpdateType.news) {
      news.remove(u.state);
    } else if (u.type == MessagOrUpdateType.b) {
      updates.remove(u.state);
    }
  }

  @action
  Future undoRemove(NotificationUpdate u) async {
    if (u.type == MessagOrUpdateType.news) {
      news[u.state] = u;
    } else if (u.type == MessagOrUpdateType.orderUpdate) {
      updates[u.state] = u;
    }
  }

  ///set viewed property to true when customer dismisses, so update doesn't show up
  @action
  Future setViewedForUpdate(NotificationUpdate update) async {
    if (_user == null) {
      return;
    }
    await _fireStore
        .doc("users/${_user.uid}/updates/${update.state}")
        .update({"viewed": true});
  }

  ///fetch updates and news from firestore
  @action
  Future getUpdates({DateTime dt}) async {
    final dateTime = dt ?? DateTime.now();
    if (_user == null) {
      return;
    }
    final updatesCollection =
        _fireStore.collection("users/${_user.uid}/updates");
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
    //print(snaps.docs);
    final allUpdates = snaps.docs.map(
      (e) => NotificationUpdate.fromJson(e.data()),
    );
    _segregate(allUpdates.toList());
  }

  ///segregate news/viewed
  void _segregate(List<NotificationUpdate> allUpdates) {
    allUpdates.forEach(
      (element) {
        if (element.viewed) {
          viewed[element.state] = element;
        } else {
          if (element.type == MessagOrUpdateType.news) {
            news[element.state] = element;
          } else {
            updates[element.state] = element;
          }
        }
      },
    );
  }
}
