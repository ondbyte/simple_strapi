import 'package:bapp/classes/firebase_structures/business_details.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:mobx/mobx.dart';
import 'package:the_country_number/the_country_number.dart';

import '../../config/config_data_types.dart';
import 'business_branch.dart';

class BappUser {
  final DocumentReference myDoc;
  final String name, email;
  final TheNumber theNumber;
  final DocumentReference business;
  final Map<String, DocumentReference> branches;
  final String image;
  final userType = Observable<UserType>(UserType.customer),
      alterEgo = Observable<UserType>(UserType.customer);
  final Address address;
  final String fcmToken;
  final DocumentReference selectedBranch;

  BappUser(
      {this.business,
      this.branches,
      this.myDoc,
      this.theNumber,
      this.name,
      this.email,
      this.image,
      UserType userType,
      UserType alterEgo,
      this.address,
      this.fcmToken = "",
      this.selectedBranch}) {
    this.alterEgo.value = alterEgo ?? UserType.customer;
    this.userType.value = userType ?? UserType.customer;
  }

  static DocumentReference newReference({String docName = ""}) {
    assert(docName.isNotEmpty);
    return FirebaseFirestore.instance.collection("users").doc(docName);
  }

  Future save() async {
    await myDoc.set(toMap(), SetOptions(merge: true));
  }

  Future delete() async {
    await myDoc.delete();
  }

  BappUser updateWith(
      {String name,
      TheNumber theNumber,
      String email,
      String image,
      bool forceChange = false,
      DocumentReference business,
      Map<String, DocumentReference> branches,
      UserType userType,
      UserType alterEgo,
      DocumentReference myDoc,
      Address address,
      String fcmToken,
      DocumentReference selectedBranch}) {
    return BappUser(
      myDoc: myDoc ?? this.myDoc,
      name: name ?? this.name,
      theNumber: theNumber ?? this.theNumber,
      email: email ?? this.email,
      image: image ?? this.image,
      business: business ?? this.business,
      branches: branches ?? this.branches,
      userType: userType ?? this.userType.value,
      alterEgo: alterEgo ?? this.alterEgo.value,
      address: address ?? this.address,
      fcmToken: fcmToken ?? this.fcmToken,
      selectedBranch: selectedBranch ??
          (this.selectedBranch ??
              (this.branches.values.isNotEmpty
                  ? this.branches.values.first
                  : null)),
    );
  }

  toMap() {
    return {
      "contactNumber": theNumber?.internationalNumber ?? "",
      "email": email ?? "",
      "name": name ?? "",
      "image": image ?? "",
      "business": business,
      "branches": branches ?? {},
      "userType": EnumToString.convertToString(userType.value),
      "alterEgo": EnumToString.convertToString(alterEgo.value),
      "fcmToken": fcmToken,
      "myAddress": address?.toMap() ?? {},
      "selectedBranch": selectedBranch,
    };
  }

  static BappUser fromSnapShot({DocumentSnapshot snap}) {
    final j = snap.data();
    return BappUser(
      myDoc: snap.reference,
      theNumber: !isNullOrEmpty(j["contactNumber"])
          ? TheCountryNumber().parseNumber(
              internationalNumber: j["contactNumber"],
            )
          : null,
      name: j["name"],
      email: j["email"],
      image: j['image'],
      business: j["business"],
      branches: (j["branches"] as Map)?.map(
            (key, value) => MapEntry(
              key as String,
              value as DocumentReference,
            ),
          ) ??
          {},
      userType: EnumToString.fromString(UserType.values, j["userType"]),
      alterEgo: EnumToString.fromString(UserType.values, j["alterEgo"]),
      address: Address.fromJson(j["myAddress"] ?? {}),
      fcmToken: j["fcmToken"],
      selectedBranch: j["selectedBranch"],
    );
  }

  Future removeBranch({BusinessDetails business, BusinessBranch branch}) async {
    await business.removeBranch(branch);
    final selectedChange = {};
    if (branch.myDoc.value == selectedBranch) {
      selectedChange
          .addAll({"selectedBranch": business.branches.value[0].myDoc});
      business.selectedBranch.value = business.branches.value[0];
    }
    await myDoc.set({
      "branches.${branch.myDoc.value.id}": FieldValue.delete(),
      ...selectedChange
    }, SetOptions(merge: true));
  }

  Future addBranch({
    BusinessDetails business,
    String branchName,
    PickedLocation pickedLocation,
    Map<String, bool> imagesWithFiltered,
  }) async {
    final b = await business.addABranch(
      branchName: branchName,
      pickedLocation: pickedLocation,
      imagesWithFiltered: imagesWithFiltered,
    );
    await myDoc.set(
      {
        "branches": {b.myDoc.value.id: b.myDoc.value}
      },
      SetOptions(merge: true),
    );
  }
}

class Address {
  final String iso2, city, locality;

  Address({this.iso2, this.city, this.locality});

  static Address fromJson(Map<String, dynamic> j) {
    return Address(
      city: j["city"] ?? "",
      iso2: j["iso2"] ?? "",
      locality: j["locality"] ?? "",
    );
  }

  toMap() {
    return {
      "city": city,
      "iso2": iso2,
      "locality": locality,
    };
  }
}
