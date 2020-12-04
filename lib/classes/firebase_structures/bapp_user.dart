import 'package:bapp/config/config_data_types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:thephonenumber/thecountrynumber.dart';

class BappUser {
  final DocumentReference myDoc;
  final String name, email;
  final TheNumber theNumber;
  final DocumentReference business;
  final Map<String, DocumentReference> branches;
  final String image;
  final UserType userType, alterEgo;

  BappUser({
    this.business,
    this.branches,
    this.myDoc,
    this.theNumber,
    this.name,
    this.email,
    this.image,
    this.userType,
    this.alterEgo,
  });

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
      DocumentReference myDoc}) {
    return BappUser(
        myDoc: myDoc ?? this.myDoc,
        name: name ?? this.name,
        theNumber: theNumber ?? this.theNumber,
        email: email ?? this.email,
        image: image ?? this.image,
        business: business ?? this.business,
        branches: branches ?? this.branches,
        userType: userType ?? this.userType,
        alterEgo: alterEgo ?? this.alterEgo);
  }

  toMap() {
    return {
      "contactNumber": theNumber.internationalNumber ?? "",
      "email": email ?? "",
      "name": name ?? "",
      "image": image ?? "",
      "business": business,
      "branches": branches ?? {},
      "userType": EnumToString.convertToString(userType),
      "alterEgo": EnumToString.convertToString(alterEgo),
    };
  }

  static BappUser fromSnapShot({DocumentSnapshot snap}) {
    final j = snap.data();
    return BappUser(
      myDoc: snap.reference,
      theNumber: TheCountryNumber().parseNumber(
        internationalNumber: j["contactNumber"],
      ),
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
      userType: j["userType"],
      alterEgo: j["alterEgo"],
    );
  }
}
