import 'package:bapp/config/config.dart';
import 'package:bapp/stores/firebase_structures/business_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

class BusinessServices {
  final DocumentReference myDoc;
  final all = Observable(ObservableList<BusinessService>());

  BusinessServices({this.myDoc}) {
    _getServices(myDoc);
  }

  Future _getServices(DocumentReference myDoc) async {
    final snap = await myDoc.get();
    if (snap.exists) {
      final data = snap.data();
      data.values.forEach((element) {
        all.value.add(BusinessService.fromJson(element));
      });
    }
  }

  toMap() {
    final map = {};
    var i = 0;
    all.value.forEach((element) {
      map[i.toString()] = element.toMap();
    });
    return map;
  }

  Future saveServices() async {
    await myDoc.set(toMap());
  }
}

class BusinessService {
  final name = Observable<String>("");
  final price = Observable<double>(0.0);
  final duration = Observable<Duration>(Duration.zero);
  final description = Observable<String>("");
  final category = Observable<BusinessServiceCategory>(null);
  final image = Observable<String>("");

  BusinessService.fromJson(Map<String, dynamic> j) {
    name.value = j["name"];
    price.value = j["price"];
    duration.value = Duration(milliseconds: j["duration"]);
    description.value = j["description"];
    category.value = BusinessServiceCategory(myDoc: j["category"]);
    image.value = j["image"];
  }

  toMap() {
    return {
      "name": name.value,
      "price": price.value,
      "duration": duration.value.inMilliseconds,
      "description": description.value,
      "category": category.value,
      "image": image.value,
    };
  }
}

class BusinessServiceCategory {
  final name = Observable<String>("");
  final description = Observable<String>("");
  final image = Observable<String>("");
  final DocumentReference myDoc;

  BusinessServiceCategory({this.myDoc}) {
    _getCategories(myDoc);
  }

  Future _getCategories(DocumentReference cr) async {
    final snap = await myDoc.get();

    if (snap.exists) {
      final j = snap.data();
      this.name.value = j["name"];
      this.description.value = j["description"];
      this.image.value = j["image"];
    }
  }

  toMap() {
    return {
      "name": name.value,
      "description": description.value,
      "image": image.value,
      "myDoc": myDoc
    };
  }
}
