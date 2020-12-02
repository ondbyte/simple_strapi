import 'package:bapp/classes/firebase_structures/business_holidays.dart';
import 'package:bapp/classes/firebase_structures/business_services.dart';
import 'package:bapp/classes/firebase_structures/business_timings.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

import 'business_branch.dart';
import 'business_category.dart';

class BusinessDetails {
  final category = Observable<BusinessCategory>(null);
  final Observable<String> businessName = Observable<String>("");
  final Observable<String> contactNumber = Observable<String>("");
  final Observable<String> address = Observable<String>("");
  final Observable<GeoPoint> latlong = Observable<GeoPoint>(null);
  final Observable<String> uid = Observable<String>("");
  final branches = Observable<List<BusinessBranch>>([]);
  final selectedBranch = Observable<BusinessBranch>(null);
  final email = Observable<String>("");
  final myDoc = Observable<DocumentReference>(null);
  final type = Observable("");

  final List<ReactionDisposer> _disposers = [];

  setupReactions() {
    _disposers.add(
      reaction(
        (_) => selectedBranch.value,
        (_) {
          if (myDoc.value != null && selectedBranch.value != null) {
            try {
              myDoc.value.set(
                  {"selectedBranch": selectedBranch.value.myDoc.value},
                  SetOptions(merge: true));
            } catch (e) {
              print("Expected ERROR ; ${e.toString()}");
            }
          }
        },
      ),
    );
    _disposers.add(
      reaction(
        (_) => branches.value.length,
        (_) {
          try {
            myDoc.value.set(
              {"branches": branches.value.map((e) => e.myDoc.value).toList()},
              SetOptions(merge: true),
            );
          } catch (e) {
            print("Expected ERROR ; ${e.toString()}");
          }
        },
      ),
    );
  }

  BusinessDetails.from({
    String businessName = "",
    String contactNumber = "",
    String address = "",
    GeoPoint latlong,
    String uid = "",
    BusinessCategory category,
    List<BusinessBranch> branches,
    DocumentReference selectedBranchDoc,
    BusinessBranch selectedBranch,
    String email = "",
    DocumentReference myDoc,
    String type,
  }) {
    this.category.value = category;
    this.businessName.value = businessName;
    this.contactNumber.value = contactNumber;
    this.address.value = address;
    this.latlong.value = latlong;
    this.uid.value = uid;
    this.branches.value = branches ?? [];
    this.selectedBranch.value = selectedBranch;
    this.email.value = email;
    this.myDoc.value = myDoc;
    this.type.value = type;

    setupReactions();
  }

/*   Future _getSelectedBranchDetails(DocumentReference doc) async {
    final data = await doc.get();
    this.selectedBranch.value = BusinessBranch.fromJson(data.data());
  } */

  BusinessDetails.fromJson(Map<String, dynamic> j) {
    category.value = BusinessCategory.fromJson(j["businessCategory"]);
    businessName.value = j["businessName"] as String;
    contactNumber.value = j["contactNumber"] as String;
    address.value = j["address"] as String;
    latlong.value = j["latlong"] as GeoPoint;
    uid.value = j["uid"] as String;
    final tmp = j["branches"] as List;
    branches.value =
        tmp.map((e) => BusinessBranch(myDoc: e, business: this)).toList();
    selectedBranch.value =
        branches.value.firstWhere((b) => b.myDoc.value == j["selectedBranch"]);
    email.value = j["email"];
    myDoc.value = j["myDoc"];
    type.value = j["type"];

    setupReactions();
  }

  Map<String, dynamic> toMap() {
    return {
      "businessCategory": category.value.toMap(),
      "businessName": businessName.value,
      "contactNumber": contactNumber.value,
      "address": address.value,
      "latLong": latlong.value,
      "uid": uid.value,
      "branches": branches.value.map((e) => e.myDoc.value).toList(),
      "selectedBranch": selectedBranch.value.myDoc.value,
      "email": email.value,
      "myDoc": myDoc.value,
      "type": type.value,
    };
  }

  Future removeBranch(BusinessBranch branch) async {
    final old = branches.value;
    old.remove(branch);
    await branch.myDoc.value.delete();
    await act(() async {
      branches.value = old; //new
      if (branch.myDoc == selectedBranch.value.myDoc) {
        selectedBranch.value = branches.value[0];
      }
    });
  }

  Future addABranch({
    String branchName,
    PickedLocation pickedLocation,
    Map<String, bool> imagesWithFiltered,
  }) async {
    final imgs =
        await uploadImagesToStorageAndReturnStringList(imagesWithFiltered);

    final branch = BusinessBranch(
      business: this,
    )
      ..manager.value = null
      ..receptionist.value = null
      ..latlong.value = pickedLocation.latLong
      ..address.value = pickedLocation.address
      ..name.value = branchName
      ..images.addAll(imgs)
      ..contactNumber.value = contactNumber.value
      ..email.value = email.value
      ..rating.value = 0.0
      ..status.value = BusinessBranchActiveStatus.lead
      ..businessCategory.value = this.category.value
      ..myDoc.value = myDoc.value.parent.doc("b_" + kUUIDGen.v1())
      ..businessHolidays.value = BusinessHolidays.empty(business: this)
      ..businessTimings.value = BusinessTimings.empty()
      ..businessServices.value = BusinessServices.empty()
      ..type.value = type.value;

    await branch.saveBranch();

    final old = branches.value;
    act(() {
      branches.value = [...old, branch];
      selectedBranch.value = branch;
    });
  }

  Future saveBusiness() async {
    await myDoc.value.set(toMap());
  }

  bool anyBranchInDraft() {
    return branches.value.any(
        (element) => element.status.value == BusinessBranchActiveStatus.draft);
  }

  bool anyBranchInPublished() {
    return branches.value.any((element) =>
        element.status.value == BusinessBranchActiveStatus.published);
  }

  bool anyBranchInUnPublished() {
    return branches.value.any((element) =>
        element.status.value == BusinessBranchActiveStatus.unPublished);
  }

  @override
  int get hashCode => myDoc.value.path.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is BusinessDetails) {
      return other.hashCode == hashCode;
    }
    return false;
  }
}
