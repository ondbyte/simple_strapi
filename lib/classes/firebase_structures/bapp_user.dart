import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thephonenumber/thecountrynumber.dart';

class BappUser {
  final DocumentReference myDoc;
  final String name, email, website, facebook, instagram, image;
  final TheNumber theNumber;

  BappUser({
    this.myDoc,
    this.theNumber,
    this.name,
    this.email,
    this.website,
    this.facebook,
    this.instagram,
    this.image,
  });

  static DocumentReference newReference() {
    return FirebaseFirestore.instance.collection("users").doc(kUUIDGen.v1());
  }

  Future save() async {
    await myDoc.set(toMap(), SetOptions(merge: true));
  }

  BappUser updateWith({
    String name,
    TheNumber theNumber,
    String email,
    String image,
    String facebook,
    String instagram,
    String website,
    bool forceChange = false,
  }) {
    return BappUser(
      myDoc: this.myDoc,
      name: name ?? this.name,
      theNumber: theNumber ?? this.theNumber,
      email: email ?? this.email,
      image: image ?? this.image,
      website:
          isNullOrEmpty(this.website) || forceChange ? website : this.website,
      facebook: isNullOrEmpty(this.facebook) || forceChange
          ? facebook
          : this.facebook,
      instagram: isNullOrEmpty(this.instagram) || forceChange
          ? instagram
          : this.instagram,
    );
  }

  toMap() {
    return {
      "contactNumber": theNumber.internationalNumber,
      "email": email,
      "facebook": facebook,
      "instagram": instagram,
      "name": name,
      "image": image,
      "website": website,
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
        website: j["website"],
        facebook: j["facebook"],
        instagram: j["instagram"],
        image: j['image']);
  }
}
