import 'package:bapp/classes/firebase_structures/bapp_fcm_message.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/all_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

class UpdatesStore {
  final updates = ObservableList<BappFCMMessage>();
  final news = ObservableList<BappFCMMessage>();
  int _page = 1;
  final AllStore _allStore;

  UpdatesStore(this._allStore) {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        if (!user.isAnonymous) {
          getUpdates();
        }
      }
    });
  }

  Query _getQuery() {
    final cloudStore = _allStore.get<CloudStore>();
    final query = FirebaseFirestore.instance
        .collection("updates")
        .where("to", isEqualTo: FirebaseAuth.instance.currentUser.phoneNumber)
        .where(
          "meantTo",
          isEqualTo:
              EnumToString.convertToString(cloudStore.bappUser.userType.value),
        );
    return query;
  }

  Future getUpdates({bool nextPage = false}) async {
    final number = FirebaseAuth.instance?.currentUser?.phoneNumber ?? "";
    if (number.isEmpty) {
      Helper.printLog("Number is empty, aborting getUpdates @ updateStore");
      return;
    }
    if (nextPage) {
      _page++;
    } else {
      _page = 1;
    }
    final query = _getQuery();
    query.snapshots().listen(
      (snaps) {
        final _updates = <BappFCMMessage>[];
        if (snaps.docs.isNotEmpty) {
          snaps.docs.forEach(
            (updateSnap) {
              _updates.add(
                BappFCMMessage.fromSnap(updateSnap),
              );
            },
          );
        }
        updates.clear();
        updates.addAll(_updates);
      },
    );
  }

  int get numberOfUnreadUpdates{
    return updates.where((element) => !element.read).length??0;
  }
}
