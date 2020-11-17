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

    setupReactions();
  }

/*   Future _getSelectedBranchDetails(DocumentReference doc) async {
    final data = await doc.get();
    this.selectedBranch.value = BusinessBranch.fromJson(data.data());
  } */

  BusinessDetails.fromJson(Map<String, dynamic> j) {
    this.category.value = BusinessCategory.fromJson(j["category"]);
    this.businessName.value = j["businessName"] as String;
    this.contactNumber.value = j["contactNumber"] as String;
    this.address.value = j["address"] as String;
    this.latlong.value = j["latlong"] as GeoPoint;
    this.uid.value = j["uid"] as String;
    final tmp = j["branches"] as List;
    if (tmp != null) {
      this.branches.value =
          tmp.map((e) => BusinessBranch(myDoc: e, business: this)).toList();
    }
    this.selectedBranch.value = this
        .branches
        .value
        .firstWhere((b) => b.myDoc.value == j["selectedBranch"]);
    this.email.value = j["email"];
    this.myDoc.value = j["myDoc"];

    setupReactions();
  }

  Map<String, dynamic> toMap() {
    return {
      "category": category.value.toMap(),
      "businessName": businessName.value,
      "contactNumber": contactNumber.value,
      "address": address.value,
      "latLong": latlong.value,
      "uid": uid.value,
      "branches": branches.value.map((e) => e.myDoc.value).toList(),
      "selectedBranch": selectedBranch.value.myDoc.value,
      "email": email.value,
      "myDoc": myDoc.value,
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
      ..status.value = BusinessBranchActiveStatus.lead;

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
}
