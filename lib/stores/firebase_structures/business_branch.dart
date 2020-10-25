import 'dart:typed_data';

import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:bapp/stores/firebase_structures/business_holidays.dart';
import 'package:bapp/stores/firebase_structures/business_staff.dart';
import 'package:bapp/stores/firebase_structures/business_timings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import 'business_details.dart';

class BusinessBranch {
  DocumentReference myDoc;

  final images = Observable<List<String>>([]);
  final name = Observable<String>("");
  final address = Observable<String>("");
  final latlong = Observable<GeoPoint>(null);
  final staff = ObservableList<BusinessStaff>();
  final manager = Observable<BusinessStaff>(null);
  final receptionist = Observable<BusinessStaff>(null);
  final business = Observable<BusinessDetails>(null);
  final contactNumber = Observable<String>("");
  final email = Observable<String>("");
  final rating = Observable<double>(0.0);
  final businessServices = Observable<BusinessServices>(null);
  final businessTimings = Observable<BusinessTimings>(null);
  final businessHolidays = Observable<BusinessHolidays>(null);
  final status =
      Observable<BusinessBranchActiveStatus>(BusinessBranchActiveStatus.lead);

  BusinessBranch({this.myDoc, @required BusinessDetails business}) {
    this.business.value = business;
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

    _disposers.add(
      reaction(
        (_) => address.value,
        (_) async {
          await myDoc.update({"address": address.value});
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => name.value,
        (_) async {
          await myDoc.update({"name": name.value});
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => email.value,
        (_) async {
          await myDoc.update({"email": email.value});
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => contactNumber.value,
        (_) async {
          await myDoc.update({"contactNumber": contactNumber.value});
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
      this.staff.clear();
      this.staff.addAll(List.castFrom(j["staff"]).map((e) =>
          BusinessStaff.fromDoc(
              business: business.value, myDoc: j["manager"])));
      this.manager.value =
          BusinessStaff.fromDoc(business: business.value, myDoc: j["manager"]);
      this.receptionist.value = BusinessStaff.fromDoc(
          business: business.value, myDoc: j["receptionist"]);
      this.contactNumber.value = j["contactNumber"];
      this.email.value = j["email"];
      this.rating.value = j["rating"];
      this.businessServices.value =
          BusinessServices(myCollec: j["businessServices"]);
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
      "staff": staff.map((element) => element.myDoc).toList(),
      "manager": manager.value?.myDoc,
      "receptionist": receptionist.value?.myDoc,
      "business": business.value.myDoc,
      "myDoc": myDoc,
      "contactNumber": contactNumber.value,
      "email": email.value,
      "rating": rating.value,
      "businessServices": businessServices.value.myCollec,
      "businessTimings": businessTimings.value.myDoc,
      "businessHolidays": businessHolidays.value.myCollection,
      "status": EnumToString.convertToString(status.value),
    };
  }

  Future updateImages({Map<String, bool> imgs}) async {
    final list = await uploadImagesToStorageAndReturnStringList(imgs);

    act(() {
      images.value = list;
    });

    await myDoc.set({"images": list}, SetOptions(merge: true));
  }

  Future saveBranch() async {
    final collec = business.value.myDoc.value.collection("businessBranches");
    final doc = await collec.add(toMap());
    await act(() {
      this.myDoc = doc;
    });
  }
}

enum BusinessBranchActiveStatus {
  lead,
  draft,
  documentVerification,
  published,
  unPublished,
}
