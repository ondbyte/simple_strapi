import 'dart:typed_data';

import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/business_services.dart';
import 'package:bapp/stores/firebase_structures/business_holidays.dart';
import 'package:bapp/stores/firebase_structures/business_timings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mobx/mobx.dart';

class BusinessBranch {
  DocumentReference myDoc;

  final images = Observable<List<String>>([]);
  final name = Observable<String>("");
  final address = Observable<String>("");
  final latlong = Observable<GeoPoint>(null);
  final staff = Observable<List<DocumentReference>>([]);
  final manager = Observable<DocumentReference>(null);
  final receptionist = Observable<DocumentReference>(null);
  final business = Observable<DocumentReference>(null);
  final contactNumber = Observable<String>("");
  final email = Observable<String>("");
  final rating = Observable<double>(0.0);
  final businessServices = Observable<BusinessServices>(null);
  final businessTimings = Observable<BusinessTimings>(null);
  final businessHolidays = Observable<BusinessHolidays>(null);
  final status = Observable<BusinessBranchActiveStatus>(
      BusinessBranchActiveStatus.justApplied);

  BusinessBranch({this.myDoc}) {
    _getBranch(myDoc);
  }

  var _disposers = <ReactionDisposer>[];
  _setupReactions() {
    _disposers.add(
      reaction(
        (_) => status.value,
        (_) async {
          await myDoc
              .update({"status": EnumToString.convertToString(status.value)});
        },
      ),
    );
  }

  Future _getBranch(DocumentReference myDoc) async {
    if (myDoc == null) {
      print("WARNING: empty docRef");
      return;
    }
    final snap = await myDoc.get();
    if (snap.exists) {
      final j = snap.data();

      this.images.value = List.castFrom(j["images"]);
      this.name.value = j["name"];
      this.address.value = j["address"];
      this.latlong.value = j["latlong"];
      this.staff.value = List.castFrom(j["staff"]);
      this.manager.value = j["manager"];
      this.receptionist.value = j["receptionist"];
      this.business.value = j["business"];
      this.contactNumber.value = j["contactNumber"];
      this.email.value = j["email"];
      this.rating.value = j["rating"];
      this.businessServices.value =
          BusinessServices(myDoc: j["businessServices"]);
      this.businessTimings.value = BusinessTimings(myDoc: j["businessTimings"]);
      this.businessHolidays.value =
          BusinessHolidays(myCollection: j["businessHolidays"]);
      this.status.value = EnumToString.fromString(
          BusinessBranchActiveStatus.values, j["status"]);

      _setupReactions();
    }
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
      "myDoc": myDoc,
      "contactNumber": contactNumber.value,
      "email": email.value,
      "rating": rating.value,
      "businessServices": businessServices.value.myDoc,
      "businessTimings": businessTimings.value.myDoc,
      "businessHolidays": businessHolidays.value.myCollection,
      "status": EnumToString.convertToString(status.value),
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

    await myDoc.set({"images": paths}, SetOptions(merge: true));
  }

  Future saveBranch() async {
    final collec = business.value.collection("businessBranches");
    final doc = await collec.add(toMap());
    await act(() {
      this.myDoc = doc;
    });
  }
}

enum BusinessBranchActiveStatus {
  justApplied,
  draft,
  documentVerification,
  published,
  unPublished,
}