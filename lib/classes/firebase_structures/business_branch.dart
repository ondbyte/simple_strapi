import 'package:bapp/helpers/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:thephonenumber/thephonenumber.dart';

import '../../config/config_data_types.dart';
import '../../config/constants.dart';
import '../../helpers/extensions.dart';
import '../../helpers/helper.dart';
import 'business_category.dart';
import 'business_details.dart';
import 'business_holidays.dart';
import 'business_services.dart';
import 'business_staff.dart';
import 'business_timings.dart';

class BusinessBranch {
  final myDoc = Observable<DocumentReference>(null);

  final images = ObservableMap<String, bool>();
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
  final businessCategory = Observable<BusinessCategory>(null);
  final offers = ObservableList();
  final packages = ObservableList();

  final description = Observable("");
  final tag = Observable("");
  String iso2 = "";
  String city = "";
  String locality = "";
  ThePhoneNumber misc;

  BusinessBranch(
      {DocumentReference myDoc, @required BusinessDetails business}) {
    this.business.value = business;
    this.myDoc.value = myDoc;
    _getBranch(myDoc);
  }

  BusinessStaff getStaffFor({String name}) {
    return staff.firstWhere((s) => s.name == name);
  }

  var _disposers = <ReactionDisposer>[];
  void _setupReactions() {
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

  Future saveTimings() async {
    await myDoc.value.set(
        {"businessTimings": businessTimings.value.toMap()},
        SetOptions(
          merge: true,
        ));
  }

  Future _getBranch(DocumentReference myDoc) async {
    if (myDoc == null) {
      print("WARNING: empty docRef");
      return;
    }
    final snap = await myDoc.get();
    if (snap.exists) {
      final j = snap.data();
      _fromJson(j);
    }
    _setupReactions();
  }

  BusinessBranch.fromJson(Map<String, dynamic> j,
      {@required BusinessDetails business}) {
    this.business.value = business;
    _fromJson(j);
  }

  void _fromJson(Map<String, dynamic> j) {
    images.addAll(
      Map.fromEntries(
        List.castFrom(j["images"]).map(
          (e) => MapEntry(e, true),
        ),
      ),
    );
    myDoc.value = j["myDoc"];
    name.value = j["name"];
    address.value = j["address"];
    latlong.value = j["latlong"];
    staff.clear();
    staff.addAll(List.castFrom(j["staff"])
        .map((e) => BusinessStaff.fromJson(business: business.value, j: e)));
    manager.value = j["manager"] != null
        ? BusinessStaff.fromJson(business: business.value, j: j["manager"])
        : null;
    receptionist.value = j["receptionist"] != null
        ? BusinessStaff.fromJson(business: business.value, j: j["receptionist"])
        : null;
    contactNumber.value = j["contactNumber"];
    email.value = j["email"];
    rating.value = j["rating"];
    businessServices.value = BusinessServices.fromJsonList(
        j["businessServices"],
        branch: this);
    businessTimings.value = BusinessTimings.fromJson(j["businessTimings"]);
    businessHolidays.value = BusinessHolidays.fromJsonList(
      j["businessHolidays"],
      business: business.value,
    );
    status.value =
        EnumToString.fromString(BusinessBranchActiveStatus.values, j["status"]);
    businessCategory.value = BusinessCategory.fromJson(j["businessCategory"]);
    description.value = j["description"]??"";
    tag.value = j["tag"]??"";
    try {
      if (status.value == BusinessBranchActiveStatus.published) {
        iso2 = j["assignedAddress"]["iso2"];
        city = j["assignedAddress"]["city"];
        locality = j["assignedAddress"]["locality"];
        if(isNullOrEmpty(iso2)||isNullOrEmpty(city)){
          throw BappDataBaseError(msg: "You have not setup business correctly",whatHappened: "could not find the data you need to manually add some data to the branch document of branch "+name.value+" Did add all the details?",);
        }
        misc = ThePhoneNumberLib.parseNumber(iso2Code: iso2);
      }
    } on BappDataBaseError catch(e, s) {
      FirebaseCrashlytics.instance.recordError(
        e.msg,
        s,
        reason:e.whatHappened,
      );
      FirebaseCrashlytics.instance.sendUnsentReports();
    } catch (e){
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "images": images.keys.toList(),
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
      "businessServices": businessServices.value?.toList() ?? [],
      "businessTimings":
          businessTimings.value?.toMap() ?? BusinessTimings.empty().toMap(),
      "businessHolidays": businessHolidays.value?.toList() ?? [],
      "status": EnumToString.convertToString(status.value),
      "businessCategory": businessCategory.value.toMap(),
      "tag":tag.value,
      "description":description.value
    };
  }

  Future updateImages({Map<String, bool> imgs}) async {
    final list = await uploadImagesToStorageAndReturnStringList(imgs);

    act(() {
      images.addAll(list);
    });

    await myDoc.value
        ?.set({"images": list.keys.toList()}, SetOptions(merge: true));
  }

  Future saveBranch() async {
    await myDoc.value.set(toMap());
  }

  Future addAStaff(
      {UserType role,
      ThePhoneNumber userPhoneNumber,
      String name,
      DateTime dateOfJoining,
      Map<String, bool> images,
      List<BusinessServiceCategory> expertise}) async {
    final imgs = await uploadImagesToStorageAndReturnStringList(images);
    final s = BusinessStaff(
      business: this.business.value,
      contactNumber: userPhoneNumber,
      name: name,
      branch: business.value.selectedBranch.value,
      role: role,
      dateOfJoining: dateOfJoining,
      expertise: expertise,
      images: imgs,
    );
    staff.add(s);
  }

  Future removeAStaff(BusinessStaff s) async {
    staff.remove(s);
  }

  String getOpenTodayString(){
    final timings = businessTimings.value.getTodayTimings();
    return timings.isNotEmpty
        ? ("Open Today\n" +
        timings.first.from.toStringWithAmOrPm() +
        " to " +
        timings.last.to.toStringWithAmOrPm())
        : "Not open today";
  }
}

enum BusinessBranchActiveStatus {
  lead,
  draft,
  documentVerification,
  published,
  unPublished,
}
