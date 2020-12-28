import 'package:bapp/classes/firebase_structures/bapp_fcm_message.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

class UpdatesStore {
  final updates = ObservableList<BappFCMMessage>();
  final news = ObservableList<BappFCMMessage>();
  int _page = 1;

  UpdatesStore(){
    FirebaseAuth.instance.userChanges().listen((user) { 
      if(user!=null){
        if(!user.isAnonymous){
          getUpdates();
        }
      }
    });
  }

  Future getUpdates({bool nextPage = false}) async {
    final number = FirebaseAuth.instance?.currentUser?.phoneNumber??"";
    if(number.isEmpty){
      Helper.printLog("Number is empty, aborting getUpdates @ updateStore");
      return;
    }
    if (nextPage) {
      _page++;
    } else {
      _page = 1;
    }
    FirebaseFirestore.instance
        .collection("updates")
        .where("to",isEqualTo: FirebaseAuth.instance.currentUser.phoneNumber)
        .orderBy("time", descending: true)
        .limit(16 * _page)
        .snapshots()
        .listen((snaps) {
      final _updates = <BappFCMMessage>[];
      if (snaps.docs.isNotEmpty) {
        snaps.docs.forEach((updateSnap) {
          _updates.add(BappFCMMessage.fromSnap(updateSnap));
        });
      }
      updates.clear();
      updates.addAll(_updates);
    });
  }
}
