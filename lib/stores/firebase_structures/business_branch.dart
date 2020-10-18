import 'dart:typed_data';

import 'package:bapp/helpers/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mobx/mobx.dart';

class BusinessBranch {
  final images = Observable<List<String>>([]);
  final name = Observable<String>("");
  final address = Observable<String>("");
  final latlong = Observable<GeoPoint>(null);
  final staff = Observable<List<DocumentReference>>([]);
  final manager = Observable<DocumentReference>(null);
  final receptionist = Observable<DocumentReference>(null);
  final business = Observable<DocumentReference>(null);
  final myDoc = Observable<DocumentReference>(null);

  BusinessBranch();

  BusinessBranch.from({
    List<String> images,
    String name,
    String address,
    GeoPoint latlong,
    List<DocumentReference> staff,
    DocumentReference manager,
    DocumentReference receptionist,
    DocumentReference business,
  }) {
    this.images.value = images;
    this.name.value = name;
    this.address.value = address;
    this.latlong.value = latlong;
    this.staff.value = staff;
    this.manager.value = manager;
    this.receptionist.value = receptionist;
    this.business.value = business;
    this.myDoc.value = business.collection("businessBranches").doc(name);
  }

  BusinessBranch.fromJson(Map<String, dynamic> j) {
    this.images.value = List.castFrom(j["images"]);
    this.name.value = j["name"];
    this.address.value = j["address"];
    this.latlong.value = j["latlong"];
    this.staff.value = List.castFrom(j["staff"]);
    this.manager.value = j["manager"];
    this.receptionist.value = j["receptionist"];
    this.business.value = j["business"];
    this.myDoc.value =
        business.value.collection("businessBranches").doc(name.value);
  }

  Map<String, dynamic> toMap() {
    return {
      "images": images.value,
      "name": name.value,
      "address": address.value,
      "latlong": latlong.value,
      "staff": staff.value,
      "manager": manager.value,
      "receptionist": receptionist.value,
      "business": business.value,
      "myDoc": myDoc.value,
    };
  }

  Future updateImages(List<String> paths, List<Uint8List> datas) async {
    final storage = FirebaseStorage.instance;
    final auth = FirebaseAuth.instance;

    ///remove images
    final lastImages = images.value;
    lastImages.removeWhere((element) => paths.contains(element));

    lastImages.forEach((element) {
      storage.ref().child(element).delete();
    });

    print(paths.join("\n"));
    for (var i = 0; i < paths.length; i++) {
      if (paths[i].startsWith("local")) {
        paths[i] = paths[i].replaceFirst("local", "");
        final ref = storage.ref().child("${auth.currentUser.uid}/${paths[i]}");
        final task = ref.putData(datas[i]);
        final snap = await task.onComplete;
        paths[i] = snap.ref.path;
      }
    }

    act(() {
      images.value = paths;
    });

    print(paths.join("\n"));
    await myDoc.value.set({"images": paths}, SetOptions(merge: true));
  }
}
