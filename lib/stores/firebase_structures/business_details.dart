import 'package:bapp/helpers/helper.dart';
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
  final selectedBranchDoc = Observable<DocumentReference>(null);
  final selectedBranch = Observable<BusinessBranch>(BusinessBranch());

  BusinessDetails.from({
    String businessName,
    String contactNumber,
    String address,
    GeoPoint latlong,
    String uid,
    BusinessCategory category,
    List<BusinessBranch> branches,
    DocumentReference selectedBranchDoc,
  }) {
    this.category.value = category;
    this.businessName.value = businessName;
    this.contactNumber.value = contactNumber;
    this.address.value = address;
    this.latlong.value = latlong;
    this.uid.value = uid;
    this.branches.value = branches ?? [];
    this.selectedBranchDoc.value = selectedBranchDoc;
    getSelectedBranchDetails(selectedBranchDoc);
  }

  Future getSelectedBranchDetails(DocumentReference doc) async {
    final data = await doc.get();
    this.selectedBranch.value = BusinessBranch.fromJson(data.data());
  }

  BusinessDetails.fromJson(Map<String, dynamic> j) {
    this.category.value = BusinessCategory.fromJson(j["category"]);
    this.businessName.value = j["businessName"] as String;
    this.contactNumber.value = j["contactNumber"] as String;
    this.address.value = j["address"] as String;
    this.latlong.value = j["latlong"] as GeoPoint;
    this.uid.value = j["uid"] as String;
    final tmp = j["branches"] as List;
    if (tmp != null) {
      this.branches.value = tmp.map((e) => BusinessBranch.fromJson(e)).toList();
    }
    this.selectedBranchDoc.value = j["selectedBranch"];
    getSelectedBranchDetails(this.selectedBranchDoc.value);
  }

  Map<String, dynamic> toMap() {
    return {
      "category": category.value.toMap(),
      "businessName": businessName.value,
      "contactNumber": contactNumber.value,
      "address": address.value,
      "latLong": latlong.value,
      "uid": uid.value,
      "branches": branches.value.map((e) => e.toMap()).toList(),
      "selectedBranch": selectedBranchDoc.value,
    };
  }

  Future removeBranch(BusinessBranch branch) async {
    final old = branches.value;
    old.remove(branch);
    act(() {
      branches.value = old; //new
    });
    await branch.myDoc.value.delete();
  }
}
