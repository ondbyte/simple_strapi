import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thephonenumber/thecountrynumber.dart';

class BappUser {
  final DocumentReference myDoc;
  final String name, email, image;
  final TheNumber theNumber;

  BappUser({
    this.myDoc,
    this.theNumber,
    this.name,
    this.email,
    this.image,
  });

  static DocumentReference newReference({String docName=""}) {
    assert(docName.isNotEmpty);
    return FirebaseFirestore.instance.collection("users").doc(docName);
  }

  Future save() async {
    await myDoc.set(toMap(), SetOptions(merge: true));
  }

  Future delete() async {
    await myDoc.delete();
  }

  BappUser updateWith({
    String name,
    TheNumber theNumber,
    String email,
    String image,
    bool forceChange = false,
  }) {
    return BappUser(
      myDoc: this.myDoc,
      name: name ?? this.name,
      theNumber: theNumber ?? this.theNumber,
      email: email ?? this.email,
      image: image ?? this.image,
    );
  }

  toMap() {
    return {
      "contactNumber": theNumber.internationalNumber,
      "email": email,
      "name": name,
      "image": image,
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
        image: j['image']);
  }
}
