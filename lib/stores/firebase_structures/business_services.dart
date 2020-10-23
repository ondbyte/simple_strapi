import 'package:bapp/config/config.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/firebase_structures/business_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

class BusinessServices {
  final String myCollec;
  final all = ObservableList<BusinessService>();
  final allCategories = ObservableList<BusinessServiceCategory>();

  BusinessServices({this.myCollec}) {
    _getServices(myCollec);
  }

  Future _getServices(String myCollec) async {
    final snaps = await FirebaseFirestore.instance.collection(myCollec).get();
    if (snaps.docs.isNotEmpty) {
      snaps.docs.toList().forEach(
        (snap) {
          final data = snap.data();
          if (data.containsKey("serviceName")) {
            all.add(BusinessService.fromJson(myDoc: snap.reference, j: data));
          } else if (data.containsKey("categoryName")) {
            allCategories.add(
              BusinessServiceCategory.fromJson(
                myDoc: snap.reference,
                j: data,
              ),
            );
          }
        },
      );
    }
  }

  Future addAService({
    String serviceName,
    double price,
    Duration duration,
    String description,
    BusinessServiceCategory category,
    Map<String, bool> images,
  }) async {
    final imgs = await uploadImagesToStorageAndReturnStringList(images);
    final service = BusinessService(
        myDoc:
            FirebaseFirestore.instance.collection(myCollec).doc(kUUIDGen.v1()))
      ..category.value = category
      ..serviceName.value = serviceName
      ..price.value = price
      ..duration.value = duration
      ..description.value = description
      ..images.value.clear()
      ..images.value.addAll(imgs);

    all.add(service);
    await service.saveService();
  }

  Future addACategory({
    String categoryName,
    String description,
    Map<String, bool> images,
  }) async {
    final imgs = await uploadImagesToStorageAndReturnStringList(images);
    final category = BusinessServiceCategory(
        myDoc:
            FirebaseFirestore.instance.collection(myCollec).doc(kUUIDGen.v1()))
      ..categoryName.value = categoryName
      ..description.value = description
      ..images.value.clear()
      ..images.value.addAll(imgs);

    allCategories.add(category);
    await category.saveServiceCategory();
  }

  Future removeCategory(BusinessServiceCategory category) async {
    allCategories.remove(category);
    await category.delete();
  }
}

class BusinessService {
  final serviceName = Observable<String>("");
  final price = Observable<double>(0.0);
  final duration = Observable<Duration>(Duration.zero);
  final description = Observable<String>("");
  final category = Observable<BusinessServiceCategory>(null);
  final images = Observable(ObservableList<String>());
  final DocumentReference myDoc;

  BusinessService({this.myDoc});

  BusinessService.fromJson({this.myDoc, Map<String, dynamic> j}) {
    serviceName.value = j["serviceName"];
    price.value = j["price"];
    duration.value = Duration(milliseconds: j["duration"]);
    description.value = j["description"];
    category.value = BusinessServiceCategory(myDoc: j["category"]);
    images.value.addAll([...j["images"]]);
  }

  Future saveService() async {
    await myDoc.set(toMap());
  }

  Future delete() async {
    await myDoc.delete();
  }

  toMap() {
    return {
      "serviceName": serviceName.value,
      "price": price.value,
      "duration": duration.value.inMilliseconds,
      "description": description.value,
      "category": category.value,
      "images": images.value.toList(),
      "myDoc": myDoc
    };
  }
}

class BusinessServiceCategory {
  final categoryName = Observable<String>("");
  final description = Observable<String>("");
  final images = Observable(ObservableList<String>());
  final DocumentReference myDoc;

  BusinessServiceCategory({this.myDoc});

  BusinessServiceCategory.fromJson({this.myDoc, Map<String, dynamic> j}) {
    this.categoryName.value = j["categoryName"];
    this.description.value = j["description"];
    this.images.value.addAll([...j["images"]]);
  }

  Future saveServiceCategory() async {
    await myDoc.set(toMap());
  }

  Future delete() async {
    await myDoc.delete();
  }

  toMap() {
    return {
      "categoryName": categoryName.value,
      "description": description.value,
      "images": images.value.toList(),
      "myDoc": myDoc
    };
  }
}
