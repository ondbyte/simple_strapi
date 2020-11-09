import 'dart:typed_data';

import 'package:bapp/config/config_data_types.dart';
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
  final myDoc = Observable<DocumentReference>(null);

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

  BusinessBranch(
      {DocumentReference myDoc, @required BusinessDetails business}) {
    this.business.value = business;
    this.myDoc.value = myDoc;
    _getBranch(myDoc);
    _setupReactions();
  }

  var _disposers = <ReactionDisposer>[];
  _setupReactions() {
    _disposers.add(
      reaction(
        (_) => myDoc.value,
        (_) async {
          await myDoc.value.update({"myDoc": myDoc.value});
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => status.value,
        (_) async {
          await myDoc.value
              ?.update({"status": EnumToString.convertToString(status.value)});
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => address.value,
        (_) async {
          await myDoc.value?.update({"address": address.value});
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => name.value,
        (_) async {
          await myDoc.value?.update({"name": name.value});
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => email.value,
        (_) async {
          await myDoc.value?.update({"email": email.value});
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => contactNumber.value,
        (_) async {
          await myDoc.value?.update({"contactNumber": contactNumber.value});
        },
      ),
    );

    _disposers.add(
      reaction(
        (_) => staff.length,
        (_) async {
          final list = [];
          staff.forEach(
            (element) {
              list.add(element.toMap());
            },
          );
          await myDoc.value?.update(
            {"staff": list},
          );
        },
      ),
    );
  }

  ///get current data from firestore
  Future pull() async {
    await _getBranch(myDoc.value);
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
      this.staff.addAll(List.castFrom(j["staff"])
          .map((e) => BusinessStaff.fromJson(business: business.value, j: e)));
      this.manager.value = j["manager"] != null
          ? BusinessStaff.fromJson(business: business.value, j: j["manager"])
          : null;
      this.receptionist.value = j["receptionist"] != null
          ? BusinessStaff.fromJson(
              business: business.value, j: j["receptionist"])
          : null;
      this.contactNumber.value = j["contactNumber"];
      this.email.value = j["email"];
      this.rating.value = j["rating"];
      this.businessServices.value = BusinessServices.fromJsonList(
          j["businessServices"],
          business: business.value);
      this.businessTimings.value =
          BusinessTimings.fromJson(j["businessTimings"]);
      this.businessHolidays.value = BusinessHolidays.fromJsonList(
          j["businessHolidays"],
          business: business.value);
      this.status.value = EnumToString.fromString(
          BusinessBranchActiveStatus.values, j["status"]);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "images": images.value,
      "name": name.value,
      "address": address.value,
      "latlong": latlong.value,
      "staff": staff.map((element) => element.toMap()).toList(),
      "manager": manager.value?.toMap(),
      "receptionist": receptionist.value?.toMap(),
      "business": business.value.myDoc.value,
      "myDoc": myDoc.value,
      "contactNumber": contactNumber.value,
      "email": email.value,
      "rating": rating.value,
      "businessServices": businessServices.value.toList(),
      "businessTimings": businessTimings.value.toMap(),
      "businessHolidays": businessHolidays.value.toList(),
      "status": EnumToString.convertToString(status.value),
    };
  }

  Future updateImages({Map<String, bool> imgs}) async {
    final list = await uploadImagesToStorageAndReturnStringList(imgs);

    act(() {
      images.value = list;
    });

    await myDoc.value?.set({"images": list}, SetOptions(merge: true));
  }

  Future saveBranch() async {
    if (myDoc.value == null) {
      final collec = business.value.myDoc.value.parent;
      final doc = await collec.add(toMap());
      await act(() {
        this.myDoc.value = doc;
      });
    } else {
      await myDoc.value.set(toMap());
    }
  }

  Future addAStaff({
    UserType role,
    String uid,
    String name,
    DateTime dateOfJoining,
    Map<String, bool> images,
  }) {
    final s = BusinessStaff(
        business: this.business.value,
        name: name,
        uid: uid,
        branch: business.value.selectedBranch.value,
        role: role,
        dateOfJoining: dateOfJoining,
        images: images);
    staff.add(s);
  }
}

enum BusinessBranchActiveStatus {
  lead,
  draft,
  documentVerification,
  published,
  unPublished,
}
